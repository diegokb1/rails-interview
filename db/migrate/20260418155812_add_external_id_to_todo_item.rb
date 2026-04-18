class AddExternalIdToTodoItem < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_items, :external_id, :string
  end
end
