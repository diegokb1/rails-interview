class DeleteTodoListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info "--------Starting Todo List deletion sync----------"
    list_id = args.first
    response = ApiClient.destroy(list_id)
    unless response.status == 200
      logger.error "List delete sync failed for id #{list_id} - error: #{response.errors}"
    end
  end
end
