class DropNoteCategoriesTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :note_categories
  end
end
