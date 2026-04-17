module TodoItems
  class DeleteJob < ApplicationJob
    queue_as :default

    def perform(*args)
      Rails.logger.info "--------Starting Todo Item deletion sync----------"
      list_id = args.first
      item_id = args.last
      response = ApiClient::Items.destroy(list_id, item_id)
      unless response.status == 200
        Rails.logger.error "Item delete sync failed for id #{item_id} - error: #{response.errors}"
      end
    end
  end
end
