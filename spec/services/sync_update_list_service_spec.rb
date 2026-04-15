require 'rails_helper'

RSpec.describe SyncUpdateListService do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }

  describe '.call' do
    it 'enqueues an UpdateTodoListJob' do
      expect { SyncUpdateListService.call(todo_list) }.to have_enqueued_job(UpdateTodoListJob)
    end

    it 'enqueues the job with the list id and name' do
      SyncUpdateListService.call(todo_list)

      expect(UpdateTodoListJob).to have_been_enqueued.with(todo_list.id, todo_list.name)
    end
  end
end
