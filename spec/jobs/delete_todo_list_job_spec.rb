require 'rails_helper'

RSpec.describe DeleteTodoListJob, type: :job do
  include ActiveJob::TestHelper

  let(:list_id) { 42 }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(DeleteTodoListJob.new.queue_name).to eq('default')
    end

    it 'executes without raising an error' do
      expect { DeleteTodoListJob.perform_now(list_id) }.not_to raise_error
    end

    it 'can be enqueued' do
      expect { DeleteTodoListJob.perform_later(list_id) }.to have_enqueued_job(DeleteTodoListJob)
    end

    it 'is enqueued with the correct arguments' do
      DeleteTodoListJob.perform_later(list_id)

      expect(DeleteTodoListJob).to have_been_enqueued.with(list_id)
    end
  end
end
