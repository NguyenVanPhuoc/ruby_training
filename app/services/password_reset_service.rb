class PasswordResetService
  def self.request_reset(email)
    user = UserRepository.find_by_email(email)
    return unless user

    token = SecureRandom.urlsafe_base64
    UserRepository.update_reset_password_token(user, token)

    PasswordMailer.reset(user, token).deliver_later
  end

  def self.validate_token(token)
    user = UserRepository.find_by_reset_token(token)
    return nil unless user
    return nil if user.reset_password_sent_at < 2.hours.ago

    user
  end

  def self.update_password(token, password)
    user = validate_token(token)
    return false unless user

    UserRepository.reset_password(user, password)
  end
end
