module TodoLists
  class CreateJob < ApplicationJob
    queue_as :default

    def perform(*args)
      Rails.logger.info "--------Starting Todo List creation sync----------"
      params = JSON.parse(args.first.to_json)
      response = ApiClient::Lists.create(params)
      if response.status == 200
        TodoList.find(params['id']).update(last_synced: DateTime.now, external_id: response.body[:id])
      else
        Rails.logger.error "List create synced failed with params #{params} - error: #{response.errors}"
      end
    end
  end
end
