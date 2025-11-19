class User < ApplicationRecord
  belongs_to :team, optional: true
  has_secure_password

  ROLES = %w[super_admin admin user].freeze
  
  # DÙNG VALIDATE
  validates :name, :email, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true
  
  validate :password_confirmation_match

  validates :role, inclusion: { in: ROLES }, allow_nil: true
  
  # SCOPES:
  # Khi cần lấy danh sách tất cả admin để quản lý
  scope :admins, -> { where(role: ['super_admin', 'admin']) }
  
  # Khi cần tìm super admin để giao nhiệm vụ đặc biệt
  scope :super_admins, -> { where(role: 'super_admin') }
  
  # Khi super admin muốn quản lý các admin thường
  scope :regular_admins, -> { where(role: 'admin') }
  
  #  Khi admin thường muốn quản lý user
  scope :regular_users, -> { where(role: 'user').or(where(role: nil)) }

  # Custom validation methods
  def password_confirmation_match
    if password.present? && password != password_confirmation
      errors.add(:password_confirmation, :confirmation)
    end
  end
  
  # Permission methods
  def super_admin?
    role == 'super_admin'
  end
  
  def admin?
    role == 'admin' || super_admin?
  end
  
  def regular_user?
    !admin?
  end
  
  # Permission check methods THEO ĐÚNG YÊU CẦU
  def can_manage_users?
    admin?  # Cả super_admin và admin đều quản lý được users
  end
  
  def can_manage_admins?
    super_admin?  # CHỈ super_admin được quản lý admins
  end
  
  def can_edit_user?(target_user)
    return false unless admin?
    
    if super_admin?
      # Super admin được sửa tất cả
      true
    else
      # Admin thường chỉ được sửa user thường
      target_user.regular_user?
    end
  end
  
  def can_delete_user?(target_user)
    can_edit_user?(target_user)
  end

  # Thêm methods cho team permissions
  def can_manage_teams?
    super_admin?
  end
  
  def can_view_teams?
    admin?  # Cả super_admin và admin đều xem được
  end
  
  def can_edit_team?(team)
    super_admin?  # Chỉ super_admin sửa được team
  end
  
  def can_delete_team?(team)
    super_admin?  # Chỉ super_admin xoá được team
  end
  
  def can_manage_team_members?(team)
    super_admin? || (admin? && team.has_member?(self))
  end
end