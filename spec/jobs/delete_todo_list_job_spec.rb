require 'rails_helper'

RSpec.describe DeleteTodoListJob, type: :job do
  include ActiveJob::TestHelper

  let(:list_id) { 42 }
  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow_any_instance_of(described_class).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(DeleteTodoListJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { DeleteTodoListJob.perform_later(list_id) }.to have_enqueued_job(DeleteTodoListJob)
    end

    it 'is enqueued with the correct arguments' do
      DeleteTodoListJob.perform_later(list_id)

      expect(DeleteTodoListJob).to have_been_enqueued.with(list_id)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient).to receive(:destroy).and_return(double(status: 200)) }

      it 'calls ApiClient.destroy with the correct id' do
        expect(ApiClient).to receive(:destroy).with(list_id)
        DeleteTodoListJob.perform_now(list_id)
      end

      it 'does not log an error' do
        expect(logger_double).not_to receive(:error)
        DeleteTodoListJob.perform_now(list_id)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient).to receive(:destroy).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        DeleteTodoListJob.perform_now(list_id)
      end
    end
  end
end
