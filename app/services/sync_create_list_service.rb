class SyncCreateListService < ApplicationService
  def self.call(todo_list)
    json_list = JSON.parse(todo_list.to_json)
    json_list["source_id"] = 'dk-sys'
    json_list["items"] = todo_list.todo_items.map { |item| { source_id: 'dk-sys', description: item.description, completed: item.completed } }
    
    json_list = JSON.parse(json_list.to_json)
    CreateTodoListJob.perform_later(json_list)
  end
end
