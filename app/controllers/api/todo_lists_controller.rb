module Api
  class TodoListsController < ApplicationController
    protect_from_forgery with: :null_session

    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      render json: @todo_lists
    end

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(todo_list_params)

      ActiveRecord::Base.transaction do
        @todo_list.save!

        params[:items]&.each do |item|
          @todo_list.todo_items.create!(description: item[:description], completed: item[:completed])
        end
      end

      render json: @todo_list.as_json(include: :todo_items), status: :created
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "List creation failed with params #{@todo_list.attributes.inspect} - error: #{e}"
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # PATCH/PUT /api/todolists/:id
    def update
      todo_list = TodoList.find_by(external_id: params[:id])

      if todo_list
        if todo_list.update(todo_list_params)
          render json: todo_list, status: :ok
        else
          Rails.logger.error "List edit failed with params #{todo_list.attributes.inspect} - error: #{todo_list.errors.full_messages}"
          render json: { error: todo_list.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "Todo list not found" }, status: :not_found
      end
    end

    # DELETE /api/todolists/:id
    def destroy
      todo_list = TodoList.find_by(external_id: params[:id])

      if todo_list
        todo_list.destroy
        render json: { success: "Todo list deleted" }, status: :ok
      else
        Rails.logger.error "Could not delete list with id #{params[:id]} - record not found"
        render json: { error: "Todo list not found" }, status: :not_found
      end
    end

    private

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end

  end
end
