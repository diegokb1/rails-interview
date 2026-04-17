require 'rails_helper'

RSpec.describe TodoItems::UpdateJob, type: :job do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:todo_item) { FactoryBot.create(:todo_item, todo_list: todo_list) }
  let(:params) { { description: todo_item.description, completed: todo_item.completed } }

  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(TodoItems::UpdateJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { TodoItems::UpdateJob.perform_later(todo_list.id, todo_item.id, params) }.to have_enqueued_job(TodoItems::UpdateJob)
    end

    it 'is enqueued with the correct arguments' do
      TodoItems::UpdateJob.perform_later(todo_list.id, todo_item.id, params)

      expect(TodoItems::UpdateJob).to have_been_enqueued.with(todo_list.id, todo_item.id, params)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient::Items).to receive(:update).and_return(double(status: 200)) }

      it 'calls ApiClient.update_item with the correct arguments' do
        expect(ApiClient::Items).to receive(:update).with(todo_list.id, todo_item.id, params)
        TodoItems::UpdateJob.perform_now(todo_list.id, todo_item.id, params)
      end

      it 'updates last_synced on the todo item' do
        expect { TodoItems::UpdateJob.perform_now(todo_list.id, todo_item.id, params) }
          .to change { todo_item.reload.last_synced }.from(nil)
      end

      it 'does not log an error' do
        expect(logger_double).not_to receive(:error)
        TodoItems::UpdateJob.perform_now(todo_list.id, todo_item.id, params)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient::Items).to receive(:update).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        TodoItems::UpdateJob.perform_now(todo_list.id, todo_item.id, params)
      end

      it 'does not update last_synced' do
        expect { TodoItems::UpdateJob.perform_now(todo_list.id, todo_item.id, params) }
          .not_to change { todo_item.reload.last_synced }
      end
    end
  end
end
