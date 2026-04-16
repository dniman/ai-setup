class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Попробуйте позже." }

  def new
    render Views::Passwords::NewView.new
  end

  def create
    if user = User.find_by(email_address: params.dig(:user, :email_address))
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Если аккаунт с таким email существует, мы отправили инструкции по сбросу пароля."
  end

  def edit
    render Views::Passwords::EditView.new(user: @user, token: params[:token])
  end

  def update
    if @user.update(params.require(:user).permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Пароль успешно изменён. Войдите с новым паролем."
    else
      render Views::Passwords::EditView.new(user: @user, token: params[:token]), status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Ссылка для сброса пароля недействительна или истекла. Запросите новую."
    end
end
