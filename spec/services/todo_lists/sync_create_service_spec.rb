require 'rails_helper'

RSpec.describe TodoLists::SyncCreateService do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:todo_item) { FactoryBot.create(:todo_item, todo_list: todo_list) }
  let(:expected_payload) do
    {
      'name'      => todo_list.name,
      'source_id' => 'dk-sys',
      'items'     => [
        { 'source_id' => 'dk-sys', 'description' => todo_item.description, 'completed' => todo_item.completed }
      ]
    }
  end

  before { todo_item }

  describe '.call' do
    it 'enqueues a TodoLists::CreateJob' do
      expect { TodoLists::SyncCreateService.call(todo_list) }.to have_enqueued_job(TodoLists::CreateJob)
    end

    it 'enqueues the job with the correct payload' do
      TodoLists::SyncCreateService.call(todo_list)

      expect(TodoLists::CreateJob).to have_been_enqueued.with(hash_including(expected_payload))
    end
  end
end
