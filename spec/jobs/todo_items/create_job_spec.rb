require 'rails_helper'

RSpec.describe TodoItems::CreateJob, type: :job do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:todo_item) { FactoryBot.create(:todo_item, todo_list: todo_list) }
  let(:params) { todo_item.as_json }

  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(TodoItems::CreateJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { TodoItems::CreateJob.perform_later(todo_list.id, params) }.to have_enqueued_job(TodoItems::CreateJob)
    end

    it 'is enqueued with the correct arguments' do
      TodoItems::CreateJob.perform_later(todo_list.id, params)

      expect(TodoItems::CreateJob).to have_been_enqueued.with(todo_list.id, params)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient).to receive(:create_item).and_return(double(status: 200)) }

      it 'calls ApiClient.create_item with the correct arguments' do
        expect(ApiClient).to receive(:create_item).with(todo_list.id, params)
        TodoItems::CreateJob.perform_now(todo_list.id, params)
      end

      it 'updates last_synced on the todo item' do
        expect { TodoItems::CreateJob.perform_now(todo_list.id, params) }
          .to change { todo_item.reload.last_synced }.from(nil)
      end

      it 'does not log an error' do
        expect(logger_double).not_to receive(:error)
        TodoItems::CreateJob.perform_now(todo_list.id, params)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient).to receive(:create_item).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        TodoItems::CreateJob.perform_now(todo_list.id, params)
      end

      it 'does not update last_synced' do
        expect { TodoItems::CreateJob.perform_now(todo_list.id, params) }
          .not_to change { todo_item.reload.last_synced }
      end
    end
  end
end
