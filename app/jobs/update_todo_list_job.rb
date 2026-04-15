class UpdateTodoListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    list_id = args.first
    list_name = args.last
    # put api call here
  end
end
