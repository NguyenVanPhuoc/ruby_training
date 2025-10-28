class PasswordsController < ApplicationController
  skip_before_action :require_login
  def new
  end

  def create
    if PasswordResetService.request_reset(params[:email])
        if Rails.env.development?
            redirect_to letter_opener_web_path, notice: "Email khôi phục đã được gửi."
        else
            redirect_to login_path, notice: "Email khôi phục đã được gửi."
        end
    else
        redirect_to new_password_path, alert: "Email không tồn tại trong hệ thống."
    end
  end


  def edit
    @token = params[:token]
    @user = PasswordResetService.validate_token(@token)

    unless @user
      redirect_to new_password_path, alert: "Link reset không hợp lệ hoặc đã hết hạn."
    end
  end

  def update
    if PasswordResetService.update_password(params[:token], params[:password])
      redirect_to login_path, notice: "Đổi mật khẩu thành công!"
    else
      redirect_to new_password_path, alert: "Token không hợp lệ."
    end
  end
end
