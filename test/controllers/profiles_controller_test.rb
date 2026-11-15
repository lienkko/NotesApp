require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get show" do
    get profile_path

    assert_response :success
    assert_select "main.profile-page"
    assert_select ".profile-value", text: @user.email_address
    assert_select ".profile-value", text: "@#{@user.username}"
    assert_select "a", text: "Сменить пароль", href: new_password_path
    assert_select "form[action='#{session_path}']"
    assert_select "a.profile-home-link", text: "Вернуться домой", href: root_path
  end

  test "updates username" do
    patch profile_path, params: { user: { username: "changed_name" } }

    assert_redirected_to profile_path
    assert_equal "changed_name", @user.reload.username
  end

  test "rejects a duplicate username" do
    patch profile_path, params: { user: { username: users(:two).username } }

    assert_response :unprocessable_entity
    assert_select ".auth-message-error", /Username has already been taken/
  end

  test "changes password with the current password" do
    patch update_profile_password_path, params: {
      current_password: "password",
      password: "new-password",
      password_confirmation: "new-password"
    }

    assert_redirected_to profile_path
    assert @user.reload.authenticate("new-password")
  end

  test "rejects a password change with an incorrect current password" do
    patch update_profile_password_path, params: {
      current_password: "wrong-password",
      password: "new-password",
      password_confirmation: "new-password"
    }

    assert_response :unprocessable_entity
    assert_select ".profile-message-error", /Неверный текущий пароль/
  end
end
