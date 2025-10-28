class UserService
  def self.create_user(params)
    User.create(params)
  end

  def self.update_user(id, params)
    user = User.find(id)
    user.update(params)
    user
  end

  def self.destroy_user(id)
    User.find(id).destroy
  end
end