class AddLastSyncedToTodoList < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_lists, :last_synced, :datetime
  end
end
