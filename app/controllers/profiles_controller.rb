class ProfilesController < ApplicationController
  def show
    @user = Current.user
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
end
