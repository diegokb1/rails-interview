class TodoListsController < ApplicationController
  # GET /todolists
  def index
    @todo_lists = TodoList.all

    respond_to :html
  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new

    respond_to :html
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      TodoLists::SyncCreateService.call(@todo_list)
      redirect_to todo_list_path(@todo_list), notice: "List created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @todo_list = TodoList.find(params[:id])
  end

  def edit
    @todo_list = TodoList.find(params[:id])
  end

  def update
    @todo_list = TodoList.find(params[:id])

    if @todo_list.update(todo_list_params)
      TodoLists::SyncUpdateService.call(@todo_list)
      redirect_to todo_list_path(@todo_list), notice: "List updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_list = TodoList.find(params[:id])
    @todo_list.destroy
    TodoLists::SyncDeleteService.call(@todo_list.external_id)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to todo_lists_path, notice: "List deleted successfully." }
    end
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
