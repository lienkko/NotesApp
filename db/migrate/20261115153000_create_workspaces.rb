class CreateWorkspaces < ActiveRecord::Migration[8.1]
  def up
    create_table :workspaces do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    add_index :workspaces, [:user_id, :name], unique: true
    add_reference :notes, :workspace, foreign_key: true

    Workspace.reset_column_information
    User.find_each do |user|
      workspace = user.workspaces.create!(name: "Мои заметки")
      user.notes.update_all(workspace_id: workspace.id)
    end

    change_column_null :notes, :workspace_id, false
  end

  def down
    remove_reference :notes, :workspace, foreign_key: true
    drop_table :workspaces
  end
end
