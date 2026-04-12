class CreateToDoItem < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.string :description
      t.integer :todo_list_id
      t.boolean :completed

      t.timestamps
    end
  end
end
