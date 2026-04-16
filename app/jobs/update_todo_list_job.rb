class UpdateTodoListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info "--------Starting Todo List update sync----------"
    list_id = args.first
    params = args.last.to_json
    response = ApiClient.update(list_id, params)
    if response.status == 200
      TodoList.find(list_id).update(last_synced: DateTime.now)
    else
      logger.error "List update sync failed with params #{params} - error: #{response.errors}"
    end
  end
end
