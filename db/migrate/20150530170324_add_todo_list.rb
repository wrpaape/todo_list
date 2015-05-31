class AddTodoList< ActiveRecord::Migration
  def change
    create_table :todo_lists do |t|
      t.string :title
      t.text :joined_entries_w_boolean
      t.timestamps null: false
    end
  end
end
