module TodoItems
  class SyncDeleteService < ApplicationService
    def self.call(list_id, item_id)
      TodoItems::DeleteJob.perform_later(list_id, item_id)
    end
  end
end
