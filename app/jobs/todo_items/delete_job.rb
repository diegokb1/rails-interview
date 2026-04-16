module TodoItems
  class DeleteJob < ApplicationJob
    queue_as :default

    def perform(*args)
      logger.info "--------Starting Todo Item deletion sync----------"
      list_id = args.first
      item_id = args.last
      response = ApiClient.destroy_item(list_id, item_id)
      unless response.status == 200
        logger.error "Item delete sync failed for id #{item_id} - error: #{response.errors}"
      end
    end
  end
end
