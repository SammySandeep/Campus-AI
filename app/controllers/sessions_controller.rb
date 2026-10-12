class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  def new
    redirect_to dashboard_path if signed_in?
  end

  def create
    user = User.active.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password])
      return_to = session.delete(:return_to)
      reset_session
      session[:user_id] = user.id
      user.update_column(:last_login_at, Time.current)
      redirect_to return_to || dashboard_path, notice: "Welcome back, #{user.first_name}."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "You have been signed out."
  end
end
