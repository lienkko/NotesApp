require "test_helper"

class WorkspacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "lists only the current user's workspaces" do
    get workspaces_path

    assert_response :success
    assert_select ".note-title", text: workspaces(:one).name
    assert_select ".note-title", text: workspaces(:two).name, count: 0
  end

  test "creates a workspace" do
    assert_difference "Workspace.count", 1 do
      post workspaces_path, params: {
        workspace: { name: "Новый проект" }
      }
    end

    workspace = Workspace.order(:id).last
    assert_redirected_to notes_path(workspace_id: workspace.id)
    assert_equal @user, workspace.user
  end

  test "rejects a duplicate workspace name for the same user" do
    assert_no_difference "Workspace.count" do
      post workspaces_path, params: {
        workspace: { name: workspaces(:one).name }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".form-field"
  end
end
