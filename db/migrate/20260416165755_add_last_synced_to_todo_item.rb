class AddLastSyncedToTodoItem < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_items, :last_synced, :datetime
  end
end
