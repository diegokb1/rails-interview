module TodoItems
  class UpdateJob < ApplicationJob
    queue_as :default

    def perform(*args)
      logger.info "--------Starting Todo Item update sync----------"
      list_id = args.first
      item_id = args.second
      params = args.last
      response = ApiClient.update_item(list_id, item_id, params)
      if response.status == 200
        TodoItem.find(item_id).update(last_synced: DateTime.now)
      else
        logger.error "Item update sync failed with params #{params} - error: #{response.errors}"
      end
    end
  end
end
