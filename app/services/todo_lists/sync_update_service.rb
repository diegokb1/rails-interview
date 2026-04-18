module TodoLists
  class SyncUpdateService < ApplicationService
    def self.call(todo_list)
      TodoLists::UpdateJob.perform_later(todo_list.external_id, todo_list.name)
    end
  end
end
