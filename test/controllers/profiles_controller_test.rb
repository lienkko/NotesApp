require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    sign_in_as(User.take)

    get profile_path

    assert_response :success
    assert_select "main.profile-page"
    assert_select ".profile-value", text: User.take.email_address
    assert_select "a", text: "Сменить пароль", href: new_password_path
    assert_select "form[action='#{session_path}']"
    assert_select "a.profile-home-link", text: "Вернуться домой", href: root_path
  end
end
