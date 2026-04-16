require 'rails_helper'

describe TodoItemsController do
  before do
    @todo_list = FactoryBot.create(:todo_list)
  end

  describe 'GET new' do
    context 'when the parent todo list exists' do
      it 'returns a success code' do
        get :new, params: { todo_list_id: @todo_list.id }

        expect(response.status).to eq(200)
      end
    end

    context 'when the parent todo list does not exist' do
      it 'raises a record not found error' do
        expect {
          get :new, params: { todo_list_id: 0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST create' do
    context 'when the parent todo list exists' do
      context 'with valid params' do
        it 'redirects to the parent list' do
          post :create, params: { todo_list_id: @todo_list.id, todo_item: { description: 'Buy milk' } }

          expect(response).to redirect_to(todo_list_path(@todo_list))
        end
      end

      context 'without a description' do
        it 'returns a 422 status' do
          post :create, params: { todo_list_id: @todo_list.id, todo_item: { description: '' } }

          expect(response.status).to eq(422)
        end

        it 'renders the new template' do
          post :create, params: { todo_list_id: @todo_list.id, todo_item: { description: '' } }

          expect(response).to render_template(:new)
        end
      end
    end

    context 'when the parent todo list does not exist' do
      it 'raises a record not found error' do
        expect {
          post :create, params: { todo_list_id: 0, todo_item: { description: 'Buy milk' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET edit' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

    context 'when the parent todo list exists and the item exists' do
      it 'returns a success code' do
        get :edit, params: { todo_list_id: @todo_list.id, id: todo_item.id }

        expect(response.status).to eq(200)
      end
    end

    context 'when the parent todo list does not exist' do
      it 'raises a record not found error' do
        expect {
          get :edit, params: { todo_list_id: 0, id: todo_item.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the item does not exist' do
      it 'raises a record not found error' do
        expect {
          get :edit, params: { todo_list_id: @todo_list.id, id: 0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH update' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

    context 'when the parent todo list exists and the item exists' do
      context 'with todo_item params' do
        context 'with a valid description' do
          it 'redirects to the parent list' do
            patch :update, params: { todo_list_id: @todo_list.id, id: todo_item.id, todo_item: { description: 'Updated' } }

            expect(response).to redirect_to(todo_list_path(@todo_list))
          end
        end

        context 'without a description' do
          it 'returns a 422 status' do
            patch :update, params: { todo_list_id: @todo_list.id, id: todo_item.id, todo_item: { description: '' } }

            expect(response.status).to eq(422)
          end

          it 'renders the edit template' do
            patch :update, params: { todo_list_id: @todo_list.id, id: todo_item.id, todo_item: { description: '' } }

            expect(response).to render_template(:edit)
          end
        end
      end

      context 'without todo_item params (toggle completed)' do
        it 'redirects to the parent list' do
          patch :update, params: { todo_list_id: @todo_list.id, id: todo_item.id }, format: :html

          expect(response).to redirect_to(todo_lists_path(@todo_list))
        end

        it 'toggles the completed state' do
          expect {
            patch :update, params: { todo_list_id: @todo_list.id, id: todo_item.id }, format: :html
          }.to change { todo_item.reload.completed }.from(false).to(true)
        end
      end
    end

    context 'when the parent todo list does not exist' do
      it 'raises a record not found error' do
        expect {
          patch :update, params: { todo_list_id: 0, id: todo_item.id, todo_item: { description: 'Updated' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the item does not exist' do
      it 'raises a record not found error' do
        expect {
          patch :update, params: { todo_list_id: @todo_list.id, id: 0, todo_item: { description: 'Updated' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST complete_all' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list, completed: false) }

    context 'when the parent todo list exists' do
      it 'marks all items as completed' do
        expect {
          post :complete_all, params: { todo_list_id: @todo_list.id }, format: :html
        }.to change { todo_item.reload.completed }.from(false).to(true)
      end

      it 'redirects to the parent list' do
        post :complete_all, params: { todo_list_id: @todo_list.id }, format: :html

        expect(response).to redirect_to(todo_list_path(@todo_list))
      end

      it 'responds with turbo_stream' do
        post :complete_all, params: { todo_list_id: @todo_list.id }, format: :turbo_stream

        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      end
    end

    context 'when the parent todo list does not exist' do
      it 'raises a record not found error' do
        expect {
          post :complete_all, params: { todo_list_id: 0 }, format: :html
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

    context 'when the parent todo list exists and the item exists' do
      it 'redirects to the parent list' do
        delete :destroy, params: { todo_list_id: @todo_list.id, id: todo_item.id }, format: :html

        expect(response).to redirect_to(todo_lists_path(@todo_list))
      end
    end

    context 'when the parent todo list does not exist' do
      it 'raises a record not found error' do
        expect {
          delete :destroy, params: { todo_list_id: 0, id: todo_item.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the item does not exist' do
      it 'raises a record not found error' do
        expect {
          delete :destroy, params: { todo_list_id: @todo_list.id, id: 0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
