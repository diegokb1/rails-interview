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
      external_ids = external_lists_by_id.keys
      now = DateTime.now

      stale_lists.each do |list|
        unless external_ids.include?(list.id)
          list.destroy
          next
        end

        external_list = external_lists_by_id[list.id]
        list.update_columns(name: external_list["name"], last_synced: now)

        external_items_by_id = (external_list["todo_items"] || []).index_by { |i| i["id"] }
        external_item_ids = external_items_by_id.keys

        list.todo_items.each do |item|
          unless external_item_ids.include?(item.id)
            item.destroy
            next
          end

          external_item = external_items_by_id[item.id]
          item.update_columns(
            description: external_item["description"],
            completed: external_item["completed"],
            last_synced: now
          )
        end
      end
    end
  end
end
