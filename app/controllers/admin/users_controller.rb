module Admin
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: :update

    def index
      @users = User.order(:username)
    end

    def update
      requested_role = user_params[:role]

      if !User.roles.key?(requested_role)
        redirect_to admin_users_path, alert: "Неизвестная роль."
      elsif requested_role == "user" && @user == Current.user
        redirect_to admin_users_path, alert: "Нельзя снять роль с самого себя."
      elsif requested_role == "user" && @user.admin? && User.where(role: :admin).one?
        redirect_to admin_users_path, alert: "В системе должен остаться хотя бы один администратор."
      elsif @user.update(role: requested_role)
        redirect_to admin_users_path, notice: "Роль пользователя обновлена."
      else
        redirect_to admin_users_path, alert: "Не удалось обновить роль пользователя."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: [ :role ])
    end
  end
end
