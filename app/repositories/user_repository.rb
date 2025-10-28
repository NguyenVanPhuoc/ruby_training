# app/repositories/user_repository.rb
class UserRepository
  def self.find_by_email(email)
    User.find_by(email: email)
  end

  def self.search(keyword)
    User.where('name LIKE ?', "%#{keyword}%")
  end

  def self.all
    User.all
  end

  def self.find(id)
    User.find(id)
  end

  def self.logout(id)
    User.find(id).logout
  end

  def self.find_by_email(email)
    User.find_by(email: email.downcase)
  end

  def self.find_by_reset_token(token)
    User.find_by(reset_password_token: token)
  end

  def self.update_reset_password_token(user, token)
    user.update(
      reset_password_token: token,
      reset_password_sent_at: Time.current
    )
  end

  def self.reset_password(user, new_password)
    user.update(
      password: new_password,
      reset_password_token: nil
    )
  end
end