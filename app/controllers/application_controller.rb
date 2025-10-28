class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?
  before_action :require_login
  
  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    current_user.present?
  end
  
  def require_login
    unless logged_in?
      flash[:alert] = "Bạn cần đăng nhập để truy cập trang này."
      redirect_to login_path
    end
  end
end