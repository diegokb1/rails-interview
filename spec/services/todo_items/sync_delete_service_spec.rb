require 'rails_helper'

RSpec.describe TodoItems::SyncDeleteService do
  include ActiveJob::TestHelper

  let(:list_id) { 1 }
  let(:item_id) { 42 }

  describe '.call' do
    it 'enqueues a TodoItems::DeleteJob' do
      expect { TodoItems::SyncDeleteService.call(list_id, item_id) }.to have_enqueued_job(TodoItems::DeleteJob)
    end

    it 'enqueues the job with the list id and item id' do
      TodoItems::SyncDeleteService.call(list_id, item_id)

      expect(TodoItems::DeleteJob).to have_been_enqueued.with(list_id, item_id)
    end
  end
end
