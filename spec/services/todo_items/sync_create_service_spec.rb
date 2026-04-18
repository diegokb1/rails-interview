require 'rails_helper'

RSpec.describe TodoItems::SyncCreateService do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:todo_item) { FactoryBot.create(:todo_item, todo_list: todo_list) }

  describe '.call' do
    it 'enqueues a TodoItems::CreateJob' do
      expect { TodoItems::SyncCreateService.call(todo_item) }.to have_enqueued_job(TodoItems::CreateJob)
    end

    it 'enqueues the job with the list id and item payload including source_id' do
      TodoItems::SyncCreateService.call(todo_item)

      expect(TodoItems::CreateJob).to have_been_enqueued.with(
        todo_list.external_id,
        hash_including('source_id' => 'dk-sys')
      )
    end

    it 'enqueues the job with the correct item attributes' do
      TodoItems::SyncCreateService.call(todo_item)

      expect(TodoItems::CreateJob).to have_been_enqueued.with(
        todo_list.external_id,
        hash_including(
          'description' => todo_item.description,
          'completed'   => todo_item.completed
        )
      )
    end
  end
end
