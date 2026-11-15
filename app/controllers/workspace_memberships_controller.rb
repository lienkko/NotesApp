class WorkspaceMembershipsController < ApplicationController
  before_action :set_workspace, only: %i[create destroy]
  before_action :set_accessible_workspace, only: :leave

  def create
    username = params[:username].to_s.strip.delete_prefix("@").downcase
    user = User.find_by(username: username)

    if user.nil?
      redirect_to workspace_notes_path, alert: "Пользователь не найден."
      return
    end

    if user.id == @workspace.user_id
      redirect_to workspace_notes_path, alert: "Владелец уже является участником."
      return
    end

    membership = @workspace.workspace_memberships.find_or_initialize_by(user: user)
    if membership.persisted?
      redirect_to workspace_notes_path, alert: "Пользователь уже добавлен."
    elsif membership.save
      broadcast_workspace_refresh
      broadcast_user_refresh(user)
      redirect_to workspace_notes_path, notice: "Пользователь добавлен в рабочую область."
    else
      redirect_to workspace_notes_path, alert: "Пользователь уже добавлен."
    end
  end

  def destroy
    membership = @workspace.workspace_memberships.find_by(user_id: params[:user_id])
    removed_user_id = membership&.user_id
    if membership&.destroy
      broadcast_workspace_refresh
      broadcast_members_refresh
      broadcast_user_redirect(removed_user_id)
    end
    redirect_to workspace_notes_path, notice: "Пользователь удалён из рабочей области."
  end

  def leave
    if @workspace.user_id == Current.user.id
      redirect_to workspace_notes_path, alert: "Владелец не может выйти из своей рабочей области."
      return
    end

    membership = @workspace.workspace_memberships.find_by(user_id: Current.user.id)
    if membership&.destroy
      broadcast_workspace_refresh
      broadcast_members_refresh
      redirect_to workspaces_path, notice: "Вы вышли из рабочей области."
    else
      redirect_to workspaces_path, alert: "Вы не являетесь участником этой рабочей области."
    end
  end

private
  def set_workspace
    @workspace = Current.user.workspaces.find_by(id: params[:workspace_id])
    redirect_to workspaces_path unless @workspace
  end

  def set_accessible_workspace
    @workspace = Current.user.accessible_workspaces.find_by(id: params[:workspace_id])
    redirect_to workspaces_path unless @workspace
  end

  def workspace_notes_path
    notes_path(workspace_id: @workspace.id)
  end

  def broadcast_workspace_refresh
    Turbo::StreamsChannel.broadcast_refresh_to("workspace_#{@workspace.id}")
  end

  def broadcast_user_refresh(user)
    Turbo::StreamsChannel.broadcast_refresh_to("user_#{user.id}")
  end

  def broadcast_members_refresh
    (@workspace.members.to_a | [@workspace.user]).each do |user|
      broadcast_user_refresh(user)
    end
  end

  def broadcast_user_redirect(user_id)
    Turbo::StreamsChannel.broadcast_action_to(
      "user_#{user_id}",
      action: :redirect,
      attributes: { url: workspaces_path },
      render: false
    )
  end
end
