class AddConstraintsToNotes < ActiveRecord::Migration[8.1]
  def change
    change_column_null :notes, :user_id, false
    change_column_null :notes, :title, false

    add_foreign_key :notes, :users
    add_index :notes, :user_id
  end
end
