module TodoItems
  class SyncCreateService < ApplicationService
    def self.call(todo_item)
      json_item = JSON.parse(todo_item.to_json)
      json_item["source_id"] = 'dk-sys'
      
      json_item = JSON.parse(json_item.to_json)
      TodoItems::CreateJob.perform_later(todo_item.todo_list.id, json_item)
    end
  end
end
