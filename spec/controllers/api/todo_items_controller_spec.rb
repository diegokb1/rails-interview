require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  before do
    @todo_list = FactoryBot.create(:todo_list)
  end

  describe 'GET index' do
    context 'when the parent todo list exists' do
      let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

      it 'returns a success code' do
        get :index, params: { todo_list_id: @todo_list.external_id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns the items belonging to the list' do
        get :index, params: { todo_list_id: @todo_list.external_id }, format: :json

        items = JSON.parse(response.body)

        aggregate_failures 'includes id and description' do
          expect(items.count).to eq(1)
          expect(items[0]['id']).to eq(todo_item.id)
          expect(items[0]['description']).to eq(todo_item.description)
          expect(items[0]['todo_list_id']).to eq(@todo_list.id)
          expect(items[0]['completed']).to eq(todo_item.completed)
        end
      end
    end

    context 'when the parent todo list does not exist' do
      it 'returns a 404 status' do
        get :index, params: { todo_list_id: 0 }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        get :index, params: { todo_list_id: 0 }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end
  end

  describe 'GET show' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

    context 'when the parent todo list exists and the item exists' do
      it 'returns a success code' do
        get :show, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns the item' do
        get :show, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id }, format: :json

        item = JSON.parse(response.body)

        aggregate_failures 'includes id, description, completed' do
          expect(item['id']).to eq(todo_item.id)
          expect(item['description']).to eq(todo_item.description)
          expect(item['todo_list_id']).to eq(@todo_list.id)
          expect(item['completed']).to eq(todo_item.completed)
        end
      end
    end

    context 'when the parent todo list does not exist' do
      it 'returns a 404 status' do
        get :show, params: { todo_list_id: 0, id: todo_item.external_id }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        get :show, params: { todo_list_id: 0, id: todo_item.external_id }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end

    context 'when the item does not exist' do
      it 'returns a 404 status' do
        get :show, params: { todo_list_id: @todo_list.external_id, id: 0 }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        get :show, params: { todo_list_id: @todo_list.external_id, id: 0 }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list item not found')
      end
    end
  end

  describe 'POST create' do
    context 'when the parent todo list exists' do
      context 'with valid params' do
        it 'returns a success code' do
          post :create, params: { todo_list_id: @todo_list.external_id, todo_item: { description: 'Buy milk' } }, format: :json

          expect(response.status).to eq(200)
        end

        it 'creates and returns the new item' do
          post :create, params: { todo_list_id: @todo_list.external_id, todo_item: { description: 'Buy milk' } }, format: :json

          item = JSON.parse(response.body)

          aggregate_failures 'includes id and description' do
            expect(item['id']).to be_present
            expect(item['description']).to eq('Buy milk')
            expect(item['todo_list_id']).to eq(@todo_list.id)
          end
        end
      end

      context 'without a description' do
        it 'returns a 422 status' do
          post :create, params: { todo_list_id: @todo_list.external_id, todo_item: { description: '' } }, format: :json

          expect(response.status).to eq(422)
        end

        it 'returns validation errors' do
          post :create, params: { todo_list_id: @todo_list.external_id, todo_item: { description: '' } }, format: :json

          body = JSON.parse(response.body)

          expect(body['error']).to include("Description can't be blank")
        end
      end
    end

    context 'when the parent todo list does not exist' do
      it 'returns a 404 status' do
        post :create, params: { todo_list_id: 0, todo_item: { description: 'Buy milk' } }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        post :create, params: { todo_list_id: 0, todo_item: { description: 'Buy milk' } }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

    context 'when the parent todo list exists and the item exists' do
      context 'with valid params' do
        it 'returns a success code' do
          put :update, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id, todo_item: { description: 'Updated' } }, format: :json

          expect(response.status).to eq(200)
        end

        it 'returns the updated item' do
          put :update, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id, todo_item: { description: 'Updated' } }, format: :json

          item = JSON.parse(response.body)

          expect(item['description']).to eq('Updated')
        end
      end

      context 'with invalid params' do
        it 'returns a 422 status' do
          put :update, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id, todo_item: { description: '' } }, format: :json

          expect(response.status).to eq(422)
        end

        it 'returns validation errors' do
          put :update, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id, todo_item: { description: '' } }, format: :json

          body = JSON.parse(response.body)

          expect(body['error']).to include("Description can't be blank")
        end
      end
    end

    context 'when the parent todo list does not exist' do
      it 'returns a 404 status' do
        put :update, params: { todo_list_id: 0, id: todo_item.external_id, todo_item: { description: 'Updated' } }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        put :update, params: { todo_list_id: 0, id: todo_item.external_id, todo_item: { description: 'Updated' } }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end

    context 'when the item does not exist' do
      it 'returns a 404 status' do
        put :update, params: { todo_list_id: @todo_list.external_id, id: 0, todo_item: { description: 'Updated' } }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        put :update, params: { todo_list_id: @todo_list.external_id, id: 0, todo_item: { description: 'Updated' } }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list item not found')
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

    context 'when the parent todo list exists and the item exists' do
      it 'returns a success code' do
        delete :destroy, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns a success message' do
        delete :destroy, params: { todo_list_id: @todo_list.external_id, id: todo_item.external_id }, format: :json

        body = JSON.parse(response.body)

        expect(body['success']).to eq('Todo list item deleted')
      end
    end

    context 'when the parent todo list does not exist' do
      it 'returns a 404 status' do
        delete :destroy, params: { todo_list_id: 0, id: todo_item.external_id }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        delete :destroy, params: { todo_list_id: 0, id: todo_item.external_id }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end

    context 'when the item does not exist' do
      it 'returns a 404 status' do
        delete :destroy, params: { todo_list_id: @todo_list.external_id, id: 0 }, format: :json

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'POST complete_all' do
    let!(:todo_item) { FactoryBot.create(:todo_item, todo_list: @todo_list) }

    context 'when the parent todo list exists' do
      it 'returns a success code' do
        post :complete_all, params: { todo_list_id: @todo_list.external_id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'marks all items as completed' do
        post :complete_all, params: { todo_list_id: @todo_list.external_id }, format: :json

        items = JSON.parse(response.body)

        expect(items).to all(include('completed' => true))
      end
    end

    context 'when the parent todo list does not exist' do
      it 'returns a 404 status' do
        post :complete_all, params: { todo_list_id: 0 }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        post :complete_all, params: { todo_list_id: 0 }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end
  end
end
