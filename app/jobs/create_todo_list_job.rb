class CreateTodoListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "--------Starting Todo List creation sync----------"
    params = JSON.parse(args.first.to_json)
    response = ApiClient.create(params)
    if response.status == 200
      todo_list = TodoList.find(params['id']).update(last_synced: DateTime.now)
    else
      Rails.logger.error "List create synced failed with params #{params} - error: #{response.errors}"
    end
  end
end
