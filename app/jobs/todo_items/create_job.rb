module TodoItems
  class CreateJob < ApplicationJob
    queue_as :default

    def perform(*args)
      Rails.logger.info "--------Starting Todo Item creation sync----------"
      list_id = args.first
      params = args.last
      response = ApiClient::Items.create(list_id, params)
      if response.status == 200
        TodoItem.find(params['id']).update(last_synced: DateTime.now, external_id: response.body['id'])
      else
        Rails.logger.error "Item create sync failed with params #{params} - error: #{response.errors}"
      end
    end
  end
end
