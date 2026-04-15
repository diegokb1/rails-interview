class SyncDeleteListService < ApplicationService
  def self.call(list_id)
    DeleteTodoListJob.perform_later(list_id)
  end
end
