require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    sign_in_as(@admin)
  end

  test "admin can view users" do
    get admin_users_path

    assert_response :success
    assert_select "h1", "Пользователи"
    assert_select "h2", /@#{@user.username}/
  end

  test "admin can change a user's role" do
    patch admin_user_path(@user), params: { user: { role: "admin" } }

    assert_redirected_to admin_users_path
    assert @user.reload.admin?
  end

  test "regular user cannot access user management" do
    sign_out
    sign_in_as(@user)

    get admin_users_path

    assert_redirected_to root_path
    assert_not @user.reload.admin?
  end

  test "admin cannot remove their own role" do
    patch admin_user_path(@admin), params: { user: { role: "user" } }

    assert_redirected_to admin_users_path
    assert @admin.reload.admin?
  end

  test "seed promotes a user selected by username" do
    @admin.update!(role: :user)

    previous_username = ENV["ADMIN_USERNAME"]
    begin
      ENV["ADMIN_USERNAME"] = @admin.username
      load Rails.root.join("db/seeds.rb")
    ensure
      if previous_username
        ENV["ADMIN_USERNAME"] = previous_username
      else
        ENV.delete("ADMIN_USERNAME")
      end
    end

    assert @admin.reload.admin?
  end
end
