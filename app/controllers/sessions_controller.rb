class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Попробуйте позже." }

  def new
    render Views::Sessions::NewView.new
  end

  def create
    if user = User.authenticate_by(params.require(:user).permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      flash.now[:alert] = "Неверный email или пароль"
      render Views::Sessions::NewView.new(flash: flash), status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
