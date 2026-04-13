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
      redirect_to todo_list_path(@todo_list)
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
      redirect_to todo_list_path(@todo_list)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_list = TodoList.find(params[:id])
    @todo_list.destroy
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo_list) }
      format.html { redirect_to todo_lists_path }
    end
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
