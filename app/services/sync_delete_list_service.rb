class SyncDeleteListService < ApplicationService
  def self.call(list_id)
    TodoLists::DeleteJob.perform_later(list_id)
  end
end
