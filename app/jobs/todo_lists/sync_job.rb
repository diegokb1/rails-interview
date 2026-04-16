module TodoLists
  class SyncJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info "--------Starting Todo List syncing old records----------"

      stale_lists = TodoList.where("last_synced < ? OR last_synced IS NULL", TodoList::STALE_LIMIT.ago)
      return if stale_lists.empty?

      response = ApiClient.get_all_lists
      unless response.success?
        Rails.logger.error "Failed to fetch external lists: #{response.code}"
        return
      end

      external_lists = response.parsed_response
      external_lists_by_id = external_lists.index_by { |l| l["id"] }
      now = DateTime.now

      external_lists.each { |external_list| sync_list_create(external_list, now) }

      stale_lists.each do |list|
        external_list = external_lists_by_id[list.id]
        external_list ? sync_list_update(list, external_list, now) : delete_list(list)
      end
    end

    private

    def sync_list_create(external_list, now)
      list_id = external_list["id"]
      local_item_ids = TodoItem.where(todo_list_id: list_id).pluck(:id)

      unless TodoList.exists?(list_id)
        list = TodoList.create(id: list_id, name: external_list["name"], last_synced: now)
        unless list.persisted?
          Rails.logger.error "Failed to create list id=#{list_id}"
          return
        end
      end

      (external_list["todo_items"] || []).each do |external_item|
        sync_item_create(external_item, list_id, local_item_ids, now)
      end
    end

    def sync_list_update(list, external_list, now)
      unless list.update_columns(name: external_list["name"], last_synced: now)
        Rails.logger.error "Failed to update list id=#{list.id}"
      end

      external_items_by_id = (external_list["todo_items"] || []).index_by { |i| i["id"] }

      list.todo_items.each do |item|
        external_item = external_items_by_id[item.id]
        external_item ? sync_item_update(item, external_item, list.id, now) : delete_item(item, list.id)
      end
    end

    def delete_list(list)
      list.destroy
      Rails.logger.error "Failed to delete list id=#{list.id}" if list.persisted?
    end

    def sync_item_create(external_item, list_id, local_item_ids, now)
      return if local_item_ids.include?(external_item["id"])

      item = TodoItem.create(
        id: external_item["id"],
        todo_list_id: list_id,
        description: external_item["description"],
        completed: external_item["completed"],
        last_synced: now
      )
      Rails.logger.error "Failed to create item id=#{external_item["id"]} for list id=#{list_id}" unless item.persisted?
    end

    def sync_item_update(item, external_item, list_id, now)
      unless item.update_columns(
        description: external_item["description"],
        completed: external_item["completed"],
        last_synced: now
      )
        Rails.logger.error "Failed to update item id=#{item.id} for list id=#{list_id}"
      end
    end

    def delete_item(item, list_id)
      item.destroy
      Rails.logger.error "Failed to delete item id=#{item.id} for list id=#{list_id}" if item.persisted?
    end
  end
end
