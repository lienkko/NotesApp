require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "header.site-header"
    assert_select "a", text: "Войти", href: new_session_path
    assert_select "h1", text: /Сохраняйте важное/
  end
end
