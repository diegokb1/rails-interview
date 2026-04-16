require 'rails_helper'

RSpec.describe TodoItems::SyncBulkUpdateService do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let!(:todo_item_1) { FactoryBot.create(:todo_item, todo_list: todo_list, completed: true) }
  let!(:todo_item_2) { FactoryBot.create(:todo_item, todo_list: todo_list, completed: true) }

  describe '.call' do
    it 'enqueues a TodoItems::UpdateJob for each item' do
      expect {
        TodoItems::SyncBulkUpdateService.call(todo_list.todo_items)
      }.to have_enqueued_job(TodoItems::UpdateJob).exactly(2).times
    end

    it 'enqueues each job with the correct list id, item id and params' do
      TodoItems::SyncBulkUpdateService.call(todo_list.todo_items)

      [todo_item_1, todo_item_2].each do |todo_item|
        expect(TodoItems::UpdateJob).to have_been_enqueued.with(
          todo_list.id,
          todo_item.id,
          { description: todo_item.description, completed: todo_item.completed }
        )
      end
    end
  end
end
