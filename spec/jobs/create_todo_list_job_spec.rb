require 'rails_helper'

RSpec.describe TodoLists::CreateJob, type: :job do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:todo_item) { FactoryBot.create(:todo_item, todo_list: todo_list) }
  let(:json_list) do
    { 'id' => todo_list.id, 'name' => todo_list.name, 'source_id' => 'dk-sys', 'items' => [todo_item.as_json] }
  end

  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(TodoLists::CreateJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { TodoLists::CreateJob.perform_later(json_list) }.to have_enqueued_job(TodoLists::CreateJob)
    end

    it 'is enqueued with the correct arguments' do
      TodoLists::CreateJob.perform_later(json_list)

      expect(TodoLists::CreateJob).to have_been_enqueued.with(json_list)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient::Lists).to receive(:create).and_return(double(status: 200, body: { id: 'ext-123' })) }

      it 'calls ApiClient.create with the correct arguments' do
        expect(ApiClient::Lists).to receive(:create).with(json_list)
        TodoLists::CreateJob.perform_now(json_list)
      end

      it 'does not log an error' do
        expect(logger_double).not_to receive(:error)
        TodoLists::CreateJob.perform_now(json_list)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient::Lists).to receive(:create).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        TodoLists::CreateJob.perform_now(json_list)
      end
    end
  end
end
