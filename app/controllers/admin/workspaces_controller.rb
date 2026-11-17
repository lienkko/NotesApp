module Admin
  class WorkspacesController < ApplicationController
    before_action :require_admin
    before_action :set_user

    def index
      @workspaces = @user.accessible_workspaces
        .includes(:user, :members, :notes)
        .order(:name)
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end
  end
end
