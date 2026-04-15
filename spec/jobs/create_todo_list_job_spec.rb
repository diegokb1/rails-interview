require 'rails_helper'

RSpec.describe CreateTodoListJob, type: :job do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:todo_item) { FactoryBot.create(:todo_item, todo_list: todo_list) }
  let(:json_list) do
    { 'name' => todo_list.name, 'source_id' => 'dk-sys', 'items' => [todo_item] }
  end

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(CreateTodoListJob.new.queue_name).to eq('default')
    end

    it 'executes without raising an error' do
      expect { CreateTodoListJob.perform_now(json_list) }.not_to raise_error
    end

    it 'can be enqueued' do
      expect { CreateTodoListJob.perform_later(json_list) }.to have_enqueued_job(CreateTodoListJob)
    end

    it 'is enqueued with the correct arguments' do
      CreateTodoListJob.perform_later(json_list)

      expect(CreateTodoListJob).to have_been_enqueued.with(json_list)
    end
  end
end
