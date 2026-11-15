require "test_helper"

class WorkspaceMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @member = users(:two)
    @workspace = workspaces(:one)
    sign_in_as(@owner)
  end

  test "owner adds a user by username" do
    assert_difference "WorkspaceMembership.count", 1 do
      post workspace_members_path(@workspace), params: { username: @member.username }
    end

    assert_redirected_to notes_path(workspace_id: @workspace.id)
    assert_includes @workspace.reload.members, @member
  end

  test "owner removes a user" do
    membership = @workspace.workspace_memberships.create!(user: @member)

    assert_difference "WorkspaceMembership.count", -1 do
      delete workspace_member_path(@workspace, @member)
    end

    assert_redirected_to notes_path(workspace_id: @workspace.id)
    assert_not WorkspaceMembership.exists?(membership.id)
  end

  test "unknown username is rejected" do
    assert_no_difference "WorkspaceMembership.count" do
      post workspace_members_path(@workspace), params: { username: "missing_user" }
    end

    assert_redirected_to notes_path(workspace_id: @workspace.id)
  end

  test "member can see notes in a shared workspace" do
    @workspace.workspace_memberships.create!(user: @member)
    sign_out
    sign_in_as(@member)

    get notes_path(workspace_id: @workspace.id)

    assert_response :success
    assert_select ".note-title", text: notes(:one).title
  end

  test "non-owner cannot add users" do
    @workspace.workspace_memberships.create!(user: @member)
    sign_out
    sign_in_as(@member)

    post workspace_members_path(@workspace), params: { username: users(:two).username }

    assert_redirected_to workspaces_path
  end
end
