class AuthController < ApplicationController
  skip_before_action :require_login, only: [:login, :handle_login]
  def login
    if logged_in?
      redirect_to root_path
      return
    end
  end

  def handle_login
    user = UserRepository.find_by_email(params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to users_path, notice: 'Đã đăng nhập thành công!'
    else
      flash[:alert] = 'Email hoặc mật khẩu không đúng.'
      redirect_to login_path
    end
  end

  def logout
    reset_session
    redirect_to login_path, notice: 'Đã đăng xuất!'
  end
end