module Admin
  class WorkspaceMembershipsController < ApplicationController
    before_action :require_admin
    before_action :set_workspace

    def create
      user = User.find_by(username: normalized_username)

      if user.nil?
        redirect_back alert: "Пользователь не найден."
      elsif user.id == @workspace.user_id
        redirect_back alert: "Владелец уже является участником."
      elsif @workspace.workspace_memberships.exists?(user_id: user.id)
        redirect_back alert: "Пользователь уже добавлен."
      elsif @workspace.workspace_memberships.create(user: user).persisted?
        redirect_back notice: "Пользователь добавлен в рабочую область."
      else
        redirect_back alert: "Не удалось добавить пользователя."
      end
    end

    def destroy
      if params[:user_id].to_i == @workspace.user_id
        redirect_back alert: "Владельца нельзя удалить из рабочей области."
        return
      end

      membership = @workspace.workspace_memberships.find_by(user_id: params[:user_id])
      if membership&.destroy
        redirect_back notice: "Пользователь удалён из рабочей области."
      else
        redirect_back alert: "Участник не найден."
      end
    end

    private

    def set_workspace
      @workspace = Workspace.find(params[:workspace_id])
    end

    def normalized_username
      params[:username].to_s.strip.delete_prefix("@").downcase
    end

    def redirect_back(options)
      redirect_to admin_user_workspaces_path(@workspace.user_id), **options
    end
  end
end
