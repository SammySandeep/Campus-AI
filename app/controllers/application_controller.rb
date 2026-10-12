class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= User.active.find_by(id: session[:user_id])
  end

  def signed_in? = current_user.present?

  def authenticate_user!
    return if signed_in?
    session[:return_to] = request.fullpath if request.get? || request.head?
    redirect_to login_path, alert: "Please sign in to continue."
  end

  def require_student!
    deny_access unless current_user&.student?
  end

  def require_faculty!
    deny_access unless current_user&.faculty? || current_user&.admin?
  end

  def require_admin!
    deny_access unless current_user&.admin?
  end

  def deny_access
    respond_to do |format|
      format.html { redirect_to dashboard_path, alert: "You are not authorized to perform that action." }
      format.json { render json: { error: "forbidden" }, status: :forbidden }
    end
  end
end
