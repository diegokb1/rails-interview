require 'rails_helper'

RSpec.describe SyncDeleteListService do
  include ActiveJob::TestHelper

  let(:list_id) { 99 }

  describe '.call' do
    it 'enqueues a DeleteTodoListJob' do
      expect { SyncDeleteListService.call(list_id) }.to have_enqueued_job(DeleteTodoListJob)
    end

    it 'enqueues the job with the list id' do
      SyncDeleteListService.call(list_id)

      expect(DeleteTodoListJob).to have_been_enqueued.with(list_id)
    end
  end
end
