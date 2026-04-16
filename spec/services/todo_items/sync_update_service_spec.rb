require 'rails_helper'

RSpec.describe TodoItems::SyncUpdateService do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:todo_item) { FactoryBot.create(:todo_item, todo_list: todo_list) }

  describe '.call' do
    it 'enqueues a TodoItems::UpdateJob' do
      expect { TodoItems::SyncUpdateService.call(todo_item) }.to have_enqueued_job(TodoItems::UpdateJob)
    end

    it 'enqueues the job with the list id, item id and params' do
      TodoItems::SyncUpdateService.call(todo_item)

      expect(TodoItems::UpdateJob).to have_been_enqueued.with(
        todo_list.id,
        todo_item.id,
        { description: todo_item.description, completed: todo_item.completed }
      )
    end
  end
end
