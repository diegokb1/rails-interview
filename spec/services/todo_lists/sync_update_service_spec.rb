require 'rails_helper'

RSpec.describe TodoLists::SyncUpdateService do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }

  describe '.call' do
    it 'enqueues a TodoLists::UpdateJob' do
      expect { TodoLists::SyncUpdateService.call(todo_list) }.to have_enqueued_job(TodoLists::UpdateJob)
    end

    it 'enqueues the job with the list id and name' do
      TodoLists::SyncUpdateService.call(todo_list)

      expect(TodoLists::UpdateJob).to have_been_enqueued.with(todo_list.external_id, todo_list.name)
    end
  end
end
