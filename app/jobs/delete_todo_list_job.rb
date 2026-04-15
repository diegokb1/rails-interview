class DeleteTodoListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts JSON.parse(args.first.to_json)
    # put api call here
  end
end
