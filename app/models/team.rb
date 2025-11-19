class Team < ApplicationRecord
  has_many :users, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  # Methods
  def member_count
    users.count
  end
  
  def has_member?(user)
    users.include?(user)
  end
end