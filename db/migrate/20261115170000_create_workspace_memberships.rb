class CreateWorkspaceMemberships < ActiveRecord::Migration[8.1]
  def up
    create_table :workspace_memberships do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :workspace_memberships, [:workspace_id, :user_id], unique: true

    Workspace.reset_column_information
    Workspace.find_each do |workspace|
      WorkspaceMembership.create!(
        workspace_id: workspace.id,
        user_id: workspace.user_id
      )
    end
  end

  def down
    drop_table :workspace_memberships
  end
end
