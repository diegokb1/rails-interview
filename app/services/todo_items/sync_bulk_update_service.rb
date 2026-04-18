module TodoItems
  class SyncBulkUpdateService < ApplicationService
    def self.call(todo_items)
      todo_items.each do |todo_item|
        item_params = { description: todo_item.description, completed: todo_item.completed }
        TodoItems::UpdateJob.perform_later(todo_item.todo_list.external_id, todo_item.external_id, item_params)
      end
    end
  end
end
