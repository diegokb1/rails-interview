module TodoItems
  class CreateJob < ApplicationJob
    queue_as :default

    def perform(*args)
      logger.info "--------Starting Todo Item creation sync----------"
      list_id = args.first
      params = args.last
      response = ApiClient.create_item(list_id, params)
      if response.status == 200
        TodoItem.find(params['id']).update(last_synced: DateTime.now)
      else
        logger.error "Item create sync failed with params #{params} - error: #{response.errors}"
      end
    end
  end
end
