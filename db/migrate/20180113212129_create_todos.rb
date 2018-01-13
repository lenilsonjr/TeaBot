class CreateTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :todos do |t|
      t.string :todo
      t.boolean :completed, default: false
      t.boolean :deleted, default: false
      t.string :username, index: true

      t.timestamps
    end
  end
end
