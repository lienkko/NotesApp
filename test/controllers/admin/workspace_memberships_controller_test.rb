require "test_helper"

class Admin::WorkspaceMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    @workspace = workspaces(:one)
    sign_in_as(@admin)
  end

  test "admin adds a user to a workspace" do
    assert_difference "WorkspaceMembership.count", 1 do
      post admin_workspace_members_path(@workspace), params: { username: @user.username }
    end

    assert_redirected_to admin_user_workspaces_path(@workspace.user)
    assert @workspace.reload.members.include?(@user)
  end

  test "admin removes a member from a workspace" do
    membership = @workspace.workspace_memberships.create!(user: @user)

    assert_difference "WorkspaceMembership.count", -1 do
      delete admin_workspace_member_path(@workspace, @user)
    end

    assert_redirected_to admin_user_workspaces_path(@workspace.user)
    assert_not WorkspaceMembership.exists?(membership.id)
  end

  test "admin cannot remove the workspace owner" do
    assert_no_difference "WorkspaceMembership.count" do
      delete admin_workspace_member_path(@workspace, @workspace.user)
    end

    assert_redirected_to admin_user_workspaces_path(@workspace.user)
    assert WorkspaceMembership.exists?(workspace_memberships(:one).id)
  end

  test "regular user cannot manage workspace members" do
    sign_out
    sign_in_as(@user)

    post admin_workspace_members_path(@workspace), params: { username: @user.username }

    assert_redirected_to root_path
  end
end
