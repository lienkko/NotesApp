class ProfilesController < ApplicationController
  before_action :require_authentication
  before_action :set_profile, only: %i[ show edit update edit_password update_password ]

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Имя пользователя успешно изменено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit_password
  end

  def update_password
    unless @user.authenticate(params[:current_password])
      @user.errors.add(:current_password, "Неверный текущий пароль.")
      render :edit_password, status: :unprocessable_entity
      return
    end

    if @user.update(password_params)
      redirect_to profile_path, notice: "Пароль успешно изменён."
    else
      render :edit_password, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @user = Current.user
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def profile_params
    params.expect(user: [ :username ])
  end
end
