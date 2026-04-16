require 'rails_helper'

RSpec.describe CreateTodoListJob, type: :job do
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
      expect(CreateTodoListJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { CreateTodoListJob.perform_later(json_list) }.to have_enqueued_job(CreateTodoListJob)
    end

    it 'is enqueued with the correct arguments' do
      CreateTodoListJob.perform_later(json_list)

      expect(CreateTodoListJob).to have_been_enqueued.with(json_list)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient).to receive(:create).and_return(double(status: 200)) }

      it 'calls ApiClient.create with the correct arguments' do
        expect(ApiClient).to receive(:create).with(json_list)
        CreateTodoListJob.perform_now(json_list)
      end

      it 'does not log an error' do
        expect(logger_double).not_to receive(:error)
        CreateTodoListJob.perform_now(json_list)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient).to receive(:create).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        CreateTodoListJob.perform_now(json_list)
      end
    end
  end
end
