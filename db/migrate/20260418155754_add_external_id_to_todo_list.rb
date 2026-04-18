class AddExternalIdToTodoList < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_lists, :external_id, :string
  end
end
