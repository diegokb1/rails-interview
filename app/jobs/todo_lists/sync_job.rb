module TodoLists
  class SyncJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info "--------Starting Todo List syncing old records----------"

      stale_lists = TodoList.where("last_synced < ? OR last_synced IS NULL", TodoList::STALE_LIMIT.ago)
      return if stale_lists.empty?

      response = ApiClient::Lists.get_all
      unless response.success?
        Rails.logger.error "Failed to fetch external lists: #{response.code}"
        return
      end

      external_lists = response.parsed_response
      external_lists_by_ext_id = external_lists.index_by { |l| l["id"] }
      now = DateTime.now

      external_lists.each { |external_list| sync_list_create(external_list, now) }

      stale_lists.each do |list|
        external_list = external_lists_by_ext_id[list.external_id]
        external_list ? sync_list_update(list, external_list, now) : delete_list(list)
      end
    end

    private

    def sync_list_create(external_list, now)
      ext_id = external_list["id"]
      local_list = TodoList.find_by(external_id: ext_id)

      unless local_list
        local_list = TodoList.create(external_id: ext_id, name: external_list["name"], last_synced: now)
        unless local_list.persisted?
          Rails.logger.error "Failed to create list external_id=#{ext_id}"
          return
        end
      end

      local_item_ext_ids = local_list.todo_items.pluck(:external_id)

      (external_list["todo_items"] || []).each do |external_item|
        sync_item_create(external_item, local_list, local_item_ext_ids, now)
      end
    end

    def sync_list_update(list, external_list, now)
      unless list.update_columns(name: external_list["name"], last_synced: now)
        Rails.logger.error "Failed to update list external_id=#{list.external_id}"
      end

      external_items_by_ext_id = (external_list["todo_items"] || []).index_by { |i| i["id"] }

      list.todo_items.each do |item|
        external_item = external_items_by_ext_id[item.external_id]
        external_item ? sync_item_update(item, external_item, now) : delete_item(item)
      end
    end

    def delete_list(list)
      list.destroy
      Rails.logger.error "Failed to delete list external_id=#{list.external_id}" if list.persisted?
    end

    def sync_item_create(external_item, list, local_item_ext_ids, now)
      return if local_item_ext_ids.include?(external_item["id"])

      item = TodoItem.create(
        external_id: external_item["id"],
        todo_list: list,
        description: external_item["description"],
        completed: external_item["completed"],
        last_synced: now
      )
      Rails.logger.error "Failed to create item external_id=#{external_item["id"]} for list external_id=#{list.external_id}" unless item.persisted?
    end

    def sync_item_update(item, external_item, now)
      unless item.update_columns(
        description: external_item["description"],
        completed: external_item["completed"],
        last_synced: now
      )
        Rails.logger.error "Failed to update item external_id=#{item.external_id}"
      end
    end

    def delete_item(item)
      item.destroy
      Rails.logger.error "Failed to delete item external_id=#{item.external_id}" if item.persisted?
    end
  end
end
