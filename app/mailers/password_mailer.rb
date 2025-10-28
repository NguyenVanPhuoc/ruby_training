class PasswordMailer < ApplicationMailer
  def reset(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Khôi phục mật khẩu")
  end
end
