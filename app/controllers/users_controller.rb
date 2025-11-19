class UsersController < ApplicationController
  layout 'admin'
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :require_admin, except: [:index]

  def index
    if current_user.super_admin?
      # Super admin: xem tất cả users (cả admin và user thường)
      users_scope = params[:search].present? ? UserRepository.search(params[:search]) : User.all
    elsif current_user.admin?
      # Admin thường: chỉ xem user thường (KHÔNG được xem admin khác)
      users_scope = params[:search].present? ? UserRepository.search(params[:search]) : User.regular_users
    else
      # User thường: chỉ xem chính mình
      users_scope = User.where(id: current_user.id)
    end
    
    @users = users_scope.page(params[:page]).per(2) # 10 items per page
  end

  def new
    @user = User.new
    @teams = TeamRepository.all
    
    # Chỉ super_admin mới được tạo admin, admin thường chỉ tạo user thường
    if current_user.super_admin?
      @available_roles = [['User', 'user'], ['Admin', 'admin'], ['Super Admin', 'super_admin']]
    elsif current_user.admin?
      @user.role = 'user' # Mặc định tạo user thường
    end
  end

  def create
    unless current_user.admin?
      redirect_to users_path, alert: 'Not authorized'
      return
    end

    # Kiểm tra quyền tạo user theo role
    user_to_create = User.new(user_params)
    
    # Admin thường KHÔNG được tạo admin khác
    if current_user.admin? && !current_user.super_admin? && user_to_create.admin?
      redirect_to users_path, alert: 'Bạn không có quyền tạo admin'
      return
    end

    @user = UserService.create_user(user_params)
    if @user.persisted?
      redirect_to users_path, notice: 'Tạo user thành công.'
    else
      @teams = TeamRepository.all
      # Set lại available_roles cho form nếu có lỗi
      if current_user.super_admin?
        @available_roles = [['User', 'user'], ['Admin', 'admin'], ['Super Admin', 'super_admin']]
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless current_user.can_edit_user?(@user)
      redirect_to users_path, alert: 'Not authorized'
      return
    end
    
    @teams = TeamRepository.all
    
    # Chỉ super_admin mới được sửa role của admin khác
    if current_user.super_admin?
      @available_roles = [['User', 'user'], ['Admin', 'admin'], ['Super Admin', 'super_admin']]
    end
  end

  def update
    unless current_user.can_edit_user?(@user)
      redirect_to users_path, alert: 'Not authorized'
      return
    end

    # Admin thường KHÔNG được chuyển user thành admin
    if current_user.admin? && !current_user.super_admin? && user_params[:role] == 'admin'
      redirect_to users_path, alert: 'Bạn không có quyền chuyển user thành admin'
      return
    end

    if UserService.update_user(@user.id, user_params)
      redirect_to users_path, notice: 'Cập nhật user thành công.'
    else
      @teams = TeamRepository.all
      # Set lại available_roles cho form nếu có lỗi
      if current_user.super_admin?
        @available_roles = [['User', 'user'], ['Admin', 'admin'], ['Super Admin', 'super_admin']]
      end
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.can_delete_user?(@user)
      redirect_to users_path, alert: 'Not authorized'
      return
    end

    # Admin thường KHÔNG được xoá admin khác
    if current_user.admin? && !current_user.super_admin? && @user.admin?
      redirect_to users_path, alert: 'Bạn không có quyền xoá admin'
      return
    end

    UserService.destroy_user(@user.id)
    redirect_to users_path, notice: 'Xoá user thành công.'
  end

  private

  def set_user
    @user = UserRepository.find(params[:id])
  end

  def require_admin
    unless current_user&.admin?
      redirect_to users_path, alert: 'Bạn không có quyền thực hiện hành động này.'
    end
  end

  def user_params
    permitted_params = [:name, :email, :password, :avatar, :team_id]
    
    # Chỉ super_admin mới được set role và chỉ khi tạo/sửa admin
    if current_user&.super_admin?
      permitted_params << :role
    end
    
    params.require(:user).permit(permitted_params)
  end
end