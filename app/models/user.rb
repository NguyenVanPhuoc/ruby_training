class User < ApplicationRecord
  belongs_to :team, optional: true
  has_secure_password
  validates :name, :email, presence: true
  validates :email, uniqueness: true

  # Optional: add avatar uploader logic here
end