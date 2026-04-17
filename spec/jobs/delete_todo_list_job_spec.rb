require 'rails_helper'

RSpec.describe TodoLists::DeleteJob, type: :job do
  include ActiveJob::TestHelper

  let(:list_id) { 42 }
  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(TodoLists::DeleteJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { TodoLists::DeleteJob.perform_later(list_id) }.to have_enqueued_job(TodoLists::DeleteJob)
    end

    it 'is enqueued with the correct arguments' do
      TodoLists::DeleteJob.perform_later(list_id)

      expect(TodoLists::DeleteJob).to have_been_enqueued.with(list_id)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient::Lists).to receive(:destroy).and_return(double(status: 200)) }

      it 'calls ApiClient.destroy with the correct id' do
        expect(ApiClient::Lists).to receive(:destroy).with(list_id)
        TodoLists::DeleteJob.perform_now(list_id)
      end

      it 'does not log an error' do
        expect(logger_double).not_to receive(:error)
        TodoLists::DeleteJob.perform_now(list_id)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient::Lists).to receive(:destroy).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        TodoLists::DeleteJob.perform_now(list_id)
      end
    end
  end
end
