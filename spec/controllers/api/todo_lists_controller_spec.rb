require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { FactoryBot.create(:todo_list, name: 'Setup RoR project') }

    it 'returns a success code' do
      get :index, format: :json

      expect(response.status).to eq(200)
    end

    it 'includes todo list records' do
      get :index, format: :json

      todo_lists = JSON.parse(response.body)

      aggregate_failures 'includes the id and name' do
        expect(todo_lists.count).to eq(1)
        expect(todo_lists[0].keys).to match_array(['id', 'name', 'last_synced', 'external_id'])
        expect(todo_lists[0]['id']).to eq(todo_list.id)
        expect(todo_lists[0]['name']).to eq(todo_list.name)
        expect(todo_lists[0]['last_synced']).to eq(todo_list.last_synced)
      end
    end
  end

  describe 'POST create' do
    context 'with valid params and no items' do
      it 'returns a 201 status' do
        post :create, params: { todo_list: { name: 'Groceries' } }, format: :json

        expect(response.status).to eq(201)
      end

      it 'creates and returns the new todo list' do
        post :create, params: { todo_list: { name: 'Groceries' } }, format: :json

        body = JSON.parse(response.body)

        aggregate_failures 'includes id, name, and empty items' do
          expect(body['id']).to be_present
          expect(body['name']).to eq('Groceries')
          expect(body['todo_items']).to eq([])
        end
      end
    end

    context 'with valid params and items' do
      let(:items) { [{ description: 'Milk', completed: false }, { description: 'Eggs', completed: true }] }

      it 'returns a 201 status' do
        post :create, params: { todo_list: { name: 'Groceries' }, items: items }, format: :json

        expect(response.status).to eq(201)
      end

      it 'creates the list with the given items' do
        post :create, params: { todo_list: { name: 'Groceries' }, items: items }, format: :json

        body = JSON.parse(response.body)

        aggregate_failures 'includes id, name, and items' do
          expect(body['name']).to eq('Groceries')
          expect(body['todo_items'].count).to eq(2)
          expect(body['todo_items'][0]['description']).to eq('Milk')
          expect(body['todo_items'][0]['completed']).to eq(false)
          expect(body['todo_items'][1]['description']).to eq('Eggs')
          expect(body['todo_items'][1]['completed']).to eq(true)
        end
      end
    end

    context 'without a name' do
      it 'returns a 422 status' do
        post :create, params: { todo_list: { name: '' } }, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns validation errors' do
        post :create, params: { todo_list: { name: '' } }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to include("Name can't be blank")
      end
    end

    context 'with an invalid item (missing description)' do
      let(:items) { [{ description: 'Milk', completed: false }, { description: '', completed: false }] }

      it 'returns a 422 status' do
        post :create, params: { todo_list: { name: 'Groceries' }, items: items }, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns the item validation errors' do
        post :create, params: { todo_list: { name: 'Groceries' }, items: items }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to include("Description can't be blank")
      end

      it 'does not persist the todo list' do
        expect {
          post :create, params: { todo_list: { name: 'Groceries' }, items: items }, format: :json
        }.not_to change(TodoList, :count)
      end

      it 'does not persist any items' do
        expect {
          post :create, params: { todo_list: { name: 'Groceries' }, items: items }, format: :json
        }.not_to change(TodoItem, :count)
      end
    end
  end

  describe 'PATCH update' do
    let!(:todo_list) { FactoryBot.create(:todo_list) }

    context 'when the todo list exists' do
      context 'with valid params' do
        it 'returns a 200 status' do
          patch :update, params: { id: todo_list.external_id, todo_list: { name: 'Updated' } }, format: :json

          expect(response.status).to eq(200)
        end

        it 'returns the updated todo list' do
          patch :update, params: { id: todo_list.external_id, todo_list: { name: 'Updated' } }, format: :json

          body = JSON.parse(response.body)

          expect(body['name']).to eq('Updated')
        end
      end

      context 'with invalid params' do
        it 'returns a 422 status' do
          patch :update, params: { id: todo_list.external_id, todo_list: { name: '' } }, format: :json

          expect(response.status).to eq(422)
        end

        it 'returns validation errors' do
          patch :update, params: { id: todo_list.external_id, todo_list: { name: '' } }, format: :json

          body = JSON.parse(response.body)

          expect(body['error']).to include("Name can't be blank")
        end
      end
    end

    context 'when the todo list does not exist' do
      it 'returns a 404 status' do
        patch :update, params: { id: 0, todo_list: { name: 'Updated' } }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        patch :update, params: { id: 0, todo_list: { name: 'Updated' } }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { FactoryBot.create(:todo_list) }

    context 'when the todo list exists' do
      it 'returns a 200 status' do
        delete :destroy, params: { id: todo_list.external_id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns a success message' do
        delete :destroy, params: { id: todo_list.external_id }, format: :json

        body = JSON.parse(response.body)

        expect(body['success']).to eq('Todo list deleted')
      end
    end

    context 'when the todo list does not exist' do
      it 'returns a 404 status' do
        delete :destroy, params: { id: 0 }, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        delete :destroy, params: { id: 0 }, format: :json

        body = JSON.parse(response.body)

        expect(body['error']).to eq('Todo list not found')
      end
    end
  end
end
