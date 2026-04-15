class SyncUpdateListService < ApplicationService
  def self.call(todo_list)
    UpdateTodoListJob.perform_later(todo_list.id, todo_list.name)
  end
end
