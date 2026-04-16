require 'rails_helper'

RSpec.describe TodoLists::SyncJob, type: :job do
  include ActiveJob::TestHelper

  let(:logger_double) { double('logger', info: nil, error: nil) }

  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  describe '#perform' do
    it 'is queued on the default queue' do
      expect(TodoLists::SyncJob.new.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect { TodoLists::SyncJob.perform_later }.to have_enqueued_job(TodoLists::SyncJob)
    end

    context 'when there are no stale lists' do
      before { FactoryBot.create(:todo_list, last_synced: (TodoList::STALE_LIMIT - 1.day).ago) }

      it 'does not call the API' do
        expect(ApiClient).not_to receive(:get_all_lists)
        TodoLists::SyncJob.perform_now
      end
    end

    context 'when there are stale lists' do
      let!(:stale_list_1) { FactoryBot.create(:todo_list, last_synced: (TodoList::STALE_LIMIT + 1.day).ago) }
      let!(:stale_list_2) { FactoryBot.create(:todo_list, last_synced: nil) }
      let!(:fresh_list)   { FactoryBot.create(:todo_list, last_synced: (TodoList::STALE_LIMIT - 1.day).ago) }

      let!(:item_1) { FactoryBot.create(:todo_item, todo_list: stale_list_1, completed: false) }
      let!(:item_2) { FactoryBot.create(:todo_item, todo_list: stale_list_1, completed: false) }

      let(:external_lists) do
        [
          {
            'id' => stale_list_1.id,
            'name' => 'Updated Name',
            'todo_items' => [
              { 'id' => item_1.id, 'description' => 'Updated desc', 'completed' => true }
            ]
          },
          {
            'id' => stale_list_2.id,
            'name' => stale_list_2.name,
            'todo_items' => []
          }
        ]
      end

      let(:successful_response) { double(success?: true, parsed_response: external_lists) }
      let(:failed_response)     { double(success?: false, code: 500) }

      context 'when the API call fails' do
        before { allow(ApiClient).to receive(:get_all_lists).and_return(failed_response) }

        it 'logs an error' do
          expect(logger_double).to receive(:error)
          TodoLists::SyncJob.perform_now
        end

        it 'does not modify any local records' do
          expect { TodoLists::SyncJob.perform_now }
            .not_to change { stale_list_1.reload.name }
        end
      end

      context 'when the API call succeeds' do
        before { allow(ApiClient).to receive(:get_all_lists).and_return(successful_response) }

        it 'updates local list attributes from external data' do
          TodoLists::SyncJob.perform_now
          expect(stale_list_1.reload.name).to eq('Updated Name')
        end

        it 'updates last_synced on synced lists' do
          expect { TodoLists::SyncJob.perform_now }
            .to change { stale_list_1.reload.last_synced }
        end

        it 'does not modify fresh lists' do
          expect { TodoLists::SyncJob.perform_now }
            .not_to change { fresh_list.reload.name }
        end

        it 'updates local item attributes from external data' do
          TodoLists::SyncJob.perform_now
          expect(item_1.reload.description).to eq('Updated desc')
          expect(item_1.reload.completed).to eq(true)
        end

        it 'updates last_synced on synced items' do
          expect { TodoLists::SyncJob.perform_now }
            .to change { item_1.reload.last_synced }
        end

        it 'destroys local items missing from external data' do
          expect { TodoLists::SyncJob.perform_now }
            .to change { TodoItem.exists?(item_2.id) }.from(true).to(false)
        end

        it 'keeps local items present in external data' do
          TodoLists::SyncJob.perform_now
          expect(TodoItem.exists?(item_1.id)).to be true
        end

        it 'destroys stale local lists missing from external data' do
          missing_list = FactoryBot.create(:todo_list, last_synced: (TodoList::STALE_LIMIT + 1.day).ago)
          TodoLists::SyncJob.perform_now
          expect(TodoList.exists?(missing_list.id)).to be false
        end

        it 'keeps stale local lists present in external data' do
          TodoLists::SyncJob.perform_now
          expect(TodoList.exists?(stale_list_1.id)).to be true
        end
      end
    end
  end
end
