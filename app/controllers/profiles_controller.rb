class ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "Имя пользователя успешно изменено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit_password
  end

  def update_password
    unless Current.user.authenticate(params[:current_password])
      redirect_to edit_profile_password_path,
                  alert: "Неверный текущий пароль."
      return
    end

    if Current.user.update(password_params)
      redirect_to profile_path, notice: "Пароль успешно изменён."
    else
      redirect_to edit_profile_password_path, alert: "Пароли не совпадают."
    end
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def profile_params
    params.expect(user: [:username])
  end
end
