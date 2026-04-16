class SyncUpdateListService < ApplicationService
  def self.call(todo_list)
    TodoLists::UpdateJob.perform_later(todo_list.id, todo_list.name)
  end
end
