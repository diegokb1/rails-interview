require 'rails_helper'

describe TodoListsController do
  before do
    @todo_list = FactoryBot.create(:todo_list)
  end

  describe 'GET index' do
    it 'returns a success code' do
      get :index

      expect(response.status).to eq(200)
    end
  end

  describe 'GET new' do
    it 'returns a success code' do
      get :new

      expect(response.status).to eq(200)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'redirects to the created list' do
        post :create, params: { todo_list: { name: 'Groceries' } }

        expect(response).to redirect_to(todo_list_path(TodoList.last))
      end

      it 'calls SyncCreateListService' do
        expect(SyncCreateListService).to receive(:call).with(an_instance_of(TodoList))

        post :create, params: { todo_list: { name: 'Groceries' } }
      end
    end

    context 'without a name' do
      it 'returns a 422 status' do
        post :create, params: { todo_list: { name: '' } }

        expect(response.status).to eq(422)
      end

      it 'renders the new template' do
        post :create, params: { todo_list: { name: '' } }

        expect(response).to render_template(:new)
      end

      it 'does not call SyncCreateListService' do
        expect(SyncCreateListService).not_to receive(:call)

        post :create, params: { todo_list: { name: '' } }
      end
    end
  end

  describe 'GET show' do
    context 'when the record exists' do
      it 'returns a success code' do
        get :show, params: { id: @todo_list.id }

        expect(response.status).to eq(200)
      end
    end

    context 'when the record does not exist' do
      it 'returns a 404 status' do
        expect {
          get :show, params: { id: 0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET edit' do
    context 'when the record exists' do
      it 'returns a success code' do
        get :edit, params: { id: @todo_list.id }

        expect(response.status).to eq(200)
      end
    end

    context 'when the record does not exist' do
      it 'raises a record not found error' do
        expect {
          get :edit, params: { id: 0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH update' do
    context 'when the record exists' do
      context 'with valid params' do
        it 'redirects to the updated list' do
          patch :update, params: { id: @todo_list.id, todo_list: { name: 'Updated' } }

          expect(response).to redirect_to(todo_list_path(@todo_list))
        end

        it 'calls SyncUpdateListService' do
          expect(SyncUpdateListService).to receive(:call).with(@todo_list)

          patch :update, params: { id: @todo_list.id, todo_list: { name: 'Updated' } }
        end
      end

      context 'without a name' do
        it 'returns a 422 status' do
          patch :update, params: { id: @todo_list.id, todo_list: { name: '' } }

          expect(response.status).to eq(422)
        end

        it 'renders the edit template' do
          patch :update, params: { id: @todo_list.id, todo_list: { name: '' } }

          expect(response).to render_template(:edit)
        end

        it 'does not call SyncUpdateListService' do
          expect(SyncUpdateListService).not_to receive(:call)

          patch :update, params: { id: @todo_list.id, todo_list: { name: '' } }
        end
      end
    end

    context 'when the record does not exist' do
      it 'raises a record not found error' do
        expect {
          patch :update, params: { id: 0, todo_list: { name: 'Updated' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when the record exists' do
      it 'redirects to the index' do
        delete :destroy, params: { id: @todo_list.id }, format: :html

        expect(response).to redirect_to(todo_lists_path)
      end

      it 'calls SyncDeleteListService' do
        expect(SyncDeleteListService).to receive(:call).with(@todo_list.id)

        delete :destroy, params: { id: @todo_list.id }, format: :html
      end
    end

    context 'when the record does not exist' do
      it 'raises a record not found error' do
        expect {
          delete :destroy, params: { id: 0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
