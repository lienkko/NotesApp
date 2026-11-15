require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "creates an account with a unique username" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          username: "new_user",
          email_address: "new@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to profile_path
    assert_equal "new_user", User.order(:id).last.username
  end

  test "rejects a duplicate username" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          username: users(:one).username,
          email_address: "another@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".auth-message-error", /Username has already been taken/
  end
end
