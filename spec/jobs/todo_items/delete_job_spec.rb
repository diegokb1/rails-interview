require 'rails_helper'

RSpec.describe TodoItems::DeleteJob, type: :job do
  include ActiveJob::TestHelper

  let(:list_id) { 1 }
  let(:item_id) { 42 }

  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow_any_instance_of(described_class).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(TodoItems::DeleteJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { TodoItems::DeleteJob.perform_later(list_id, item_id) }.to have_enqueued_job(TodoItems::DeleteJob)
    end

    it 'is enqueued with the correct arguments' do
      TodoItems::DeleteJob.perform_later(list_id, item_id)

      expect(TodoItems::DeleteJob).to have_been_enqueued.with(list_id, item_id)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient).to receive(:destroy_item).and_return(double(status: 200)) }

      it 'calls ApiClient.destroy_item with the correct arguments' do
        expect(ApiClient).to receive(:destroy_item).with(list_id, item_id)
        TodoItems::DeleteJob.perform_now(list_id, item_id)
      end

      it 'does not log an error' do
        expect(logger_double).not_to receive(:error)
        TodoItems::DeleteJob.perform_now(list_id, item_id)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient).to receive(:destroy_item).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        TodoItems::DeleteJob.perform_now(list_id, item_id)
      end
    end
  end
end
