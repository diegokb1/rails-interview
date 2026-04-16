module Api
  class TodoItemsController < ApplicationController
    protect_from_forgery with: :null_session
  
    # GET /api/todoitems
    def index
      todo_list = TodoList.find_by(id: params[:todo_list_id])
      if todo_list
        @list_items = todo_list.todo_items
        render json: @list_items
      else
        return render json: { error: "Todo list not found" }, status: :not_found
      end
      
    end

    def show
      todo_list = TodoList.find_by(id: params[:todo_list_id])
      if todo_list
        @list_item = todo_list.todo_items.find_by(id: params[:id])
        if @list_item
          render json: @list_item
        else
          return render json: { error: "Todo list item not found" }, status: :not_found
        end
        
      else
        return render json: { error: "Todo list not found" }, status: :not_found
      end
      
    end

    def create
      todo_list = TodoList.find_by(id: params[:todo_list_id])
      if todo_list
        new_item = todo_list.todo_items.create(todo_item_params)
        if new_item.save
          render json: new_item
        else
          logger.error "Item creation failed with params #{new_item.attributes.inspect} - error: #{new_item.errors.full_messages}"

          return render json: { error: new_item.errors.full_messages }, status: :unprocessable_entity
        end
      else
        return render json: { error: "Todo list not found" }, status: :not_found
      end
    end

    def update
      todo_list = TodoList.find_by(id: params[:todo_list_id])
      if todo_list
        list_item = todo_list.todo_items.find_by(id: params[:id])
        if list_item
          if list_item.update(todo_item_params)
          render json: list_item
        else
          logger.error "Item update failed with params #{list_item.attributes.inspect} - error: #{list_item.errors.full_messages}"
          return render json: { error: list_item.errors.full_messages }, status: :unprocessable_entity
        end
        else
          return render json: { error: "Todo list item not found" }, status: :not_found
        end
        
      else
        return render json: { error: "Todo list not found" }, status: :not_found
      end
    end

    def destroy
      todo_list = TodoList.find_by(id: params[:todo_list_id])
      if todo_list
        @list_item = todo_list.todo_items.find_by(id: params[:id])
        if @list_item&.destroy
          render json: { success: "Todo list item deleted" }, status: :ok
        else
          logger.error "Item deletion failed with params - record not found"
          return render json: { error: "Todo list item not found" }, status: :not_found
        end
        
      else
        return render json: { error: "Todo list not found" }, status: :not_found
      end
      
    end

    def complete_all
      todo_list = TodoList.find_by(id: params[:todo_list_id])
      if todo_list
        todo_list.todo_items.each do |item|
          item.update(completed: true)
        end
        render json: todo_list.reload.todo_items
      else
        return render json: { error: "Todo list not found" }, status: :not_found
      end
    end

    private

    def todo_item_params
      params.require(:todo_item).permit(:description)
    end
  end
end
