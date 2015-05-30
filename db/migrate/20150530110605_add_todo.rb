class AddTodo < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string :entry
      t.boolean :completed, default: false
    end
  end
end
