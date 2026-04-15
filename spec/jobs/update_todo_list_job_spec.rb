require 'rails_helper'

RSpec.describe UpdateTodoListJob, type: :job do
  include ActiveJob::TestHelper

  let(:list_id) { 1 }
  let(:list_name) { 'My Todo List' }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(UpdateTodoListJob.new.queue_name).to eq('default')
    end

    it 'executes without raising an error' do
      expect { UpdateTodoListJob.perform_now(list_id, list_name) }.not_to raise_error
    end

    it 'can be enqueued' do
      expect { UpdateTodoListJob.perform_later(list_id, list_name) }.to have_enqueued_job(UpdateTodoListJob)
    end

    it 'is enqueued with the correct arguments' do
      UpdateTodoListJob.perform_later(list_id, list_name)

      expect(UpdateTodoListJob).to have_been_enqueued.with(list_id, list_name)
    end
  end
end
