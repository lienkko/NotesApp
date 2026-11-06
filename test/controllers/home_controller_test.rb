require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "header.notes-header"
    assert_select "main.notes-app"
    assert_select "h1", text: "Мои заметки"
    assert_select "form.search-form"
    assert_select "a", text: "+ Новая заметка"
  end
end
