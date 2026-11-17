class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, null: false, default: "user"
    add_check_constraint :users, "role IN ('user', 'admin')", name: "users_role_check"
  end
end
