module Api
  class TodoItemsController < ApplicationController
    protect_from_forgery with: :null_session

    before_action :set_todo_list

    # GET /api/todoitems
    def index
      render json: @todo_list.todo_items
    end

    def show
      list_item = @todo_list.todo_items.find_by(external_id: params[:id])
      return render json: { error: "Todo list item not found" }, status: :not_found unless list_item

      render json: list_item
    end

    def create
      new_item = @todo_list.todo_items.create(todo_item_params)
      if new_item.persisted?
        render json: new_item
      else
        Rails.logger.error "Item creation failed with params #{new_item.attributes.inspect} - error: #{new_item.errors.full_messages}"
        render json: { error: new_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      list_item = @todo_list.todo_items.find_by(external_id: params[:id])
      return render json: { error: "Todo list item not found" }, status: :not_found unless list_item

      if list_item.update(todo_item_params)
        render json: list_item
      else
        Rails.logger.error "Item update failed with params #{list_item.attributes.inspect} - error: #{list_item.errors.full_messages}"
        render json: { error: list_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      list_item = @todo_list.todo_items.find_by(external_id: params[:id])
      return render json: { error: "Todo list item not found" }, status: :not_found unless list_item

      list_item.destroy
      render json: { success: "Todo list item deleted" }, status: :ok
    end

    def complete_all
      @todo_list.todo_items.each { |item| item.update(completed: true) }
      render json: @todo_list.reload.todo_items
    end

    private

    def set_todo_list
      @todo_list = TodoList.find_by(external_id: params[:todo_list_id])
      render json: { error: "Todo list not found" }, status: :not_found unless @todo_list
    end

    def todo_item_params
      params.require(:todo_item).permit(:description, :completed)
    end
  end
end
