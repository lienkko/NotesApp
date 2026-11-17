require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "defaults new users to the user role" do
    assert_equal "user", User.new.role
    assert User.new(role: :admin).admin?
  end
end
