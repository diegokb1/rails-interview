require 'rails_helper'

RSpec.describe TodoLists::UpdateJob, type: :job do
  include ActiveJob::TestHelper

  let(:todo_list) { FactoryBot.create(:todo_list) }
  let(:params) { { name: todo_list.name } }
  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(TodoLists::UpdateJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { TodoLists::UpdateJob.perform_later(todo_list.id, params) }.to have_enqueued_job(TodoLists::UpdateJob)
    end

    it 'is enqueued with the correct arguments' do
      TodoLists::UpdateJob.perform_later(todo_list.id, params)

      expect(TodoLists::UpdateJob).to have_been_enqueued.with(todo_list.id, params)
    end

    context 'when the API call succeeds' do
      before { allow(ApiClient::Lists).to receive(:update).and_return(double(status: 200)) }

      it 'calls ApiClient.update with the correct arguments' do
        expect(ApiClient::Lists).to receive(:update).with(todo_list.id, params.to_json)
        TodoLists::UpdateJob.perform_now(todo_list.id, params)
      end

      it 'updates last_synced on the todo list' do
        expect { TodoLists::UpdateJob.perform_now(todo_list.id, params) }
          .to change { todo_list.reload.last_synced }.from(nil)
      end
    end

    context 'when the API call fails' do
      before { allow(ApiClient::Lists).to receive(:update).and_return(double(status: 500, errors: 'Internal Server Error')) }

      it 'logs an error' do
        expect(logger_double).to receive(:error)
        TodoLists::UpdateJob.perform_now(todo_list.id, params)
      end

      it 'does not update last_synced' do
        expect { TodoLists::UpdateJob.perform_now(todo_list.id, params) }
          .not_to change { todo_list.reload.last_synced }
      end
    end
  end
end
