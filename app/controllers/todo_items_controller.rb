class TodoItemsController < ApplicationController
  before_action :set_todo_list

  # GET /todolists/:todo_list_id/todoitems/new
  def new
    @todo_item = @todo_list.todo_items.new
  end

  # POST /todolists/:todo_list_id/todoitems
  def create
    @todo_item = @todo_list.todo_items.new(todo_item_params)

    if @todo_item.save
      TodoItems::SyncCreateService.call(@todo_item)
      redirect_to todo_list_path(@todo_list)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todolists/:todo_list_id/todoitems/:id/edit
  def edit
    @todo_item = @todo_list.todo_items.find(params[:id])
  end

  # PATCH /todolists/:todo_list_id/todoitems/:id
  def update
    @todo_item = @todo_list.todo_items.find(params[:id])

    if params[:todo_item]
      if @todo_item.update(todo_item_params)
        TodoItems::SyncUpdateService.call(@todo_item)
        redirect_to todo_list_path(@todo_list)
      else
        render :edit, status: :unprocessable_entity
      end
    else
      @todo_item.update(completed: !@todo_item.completed)
      TodoItems::SyncUpdateService.call(@todo_item)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@todo_item) }
        format.html { redirect_to todo_lists_path(@todo_list) }
      end
    end
  end

  # POST /todolists/:todo_list_id/todoitems/complete_all
  def complete_all
    @todo_list.todo_items.update_all(completed: true)
    TodoItems::SyncBulkUpdateService.call(@todo_list.reload.todo_items)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to todo_list_path(@todo_list) }
    end
  end

  # DELETE /todolists/:todo_list_id/todoitems/:id
  def destroy
    @todo_item = @todo_list.todo_items.find(params[:id])
    @todo_item.destroy

    TodoItems::SyncDeleteService.call(@todo_item.todo_list.id, @todo_item.id)
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo_item) }
      format.html { redirect_to todo_lists_path(@todo_list) }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:description)
  end
end
