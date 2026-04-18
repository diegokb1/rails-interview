require 'rails_helper'

RSpec.describe TodoLists::SyncDeleteService do
  include ActiveJob::TestHelper

  let(:list_id) { 99 }

  describe '.call' do
    it 'enqueues a TodoLists::DeleteJob' do
      expect { TodoLists::SyncDeleteService.call(list_id) }.to have_enqueued_job(TodoLists::DeleteJob)
    end

    it 'enqueues the job with the list id' do
      TodoLists::SyncDeleteService.call(list_id)

      expect(TodoLists::DeleteJob).to have_been_enqueued.with(list_id)
    end
  end
end
