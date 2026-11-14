class RemoveCategoryFromNotes < ActiveRecord::Migration[8.1]
  def change
    remove_column :notes, :category, :string
  end
end
