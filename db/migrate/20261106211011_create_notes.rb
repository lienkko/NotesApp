class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.integer :user_id
      t.string :title
      t.text :body
      t.string :category

      t.timestamps
    end
  end
end
