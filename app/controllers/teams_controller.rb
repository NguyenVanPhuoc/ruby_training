class TeamsController < ApplicationController
  layout 'admin'
  before_action :set_team, only: [:edit, :update, :destroy, :manage_members, :add_member, :remove_member]
  before_action :authorize_team_access, except: [:index, :manage_members, :add_member, :remove_member]

  def index
    if current_user.super_admin?
      @teams = params[:search].present? ? TeamRepository.search(params[:search]) : TeamRepository.all
    elsif current_user.admin?
      @teams = params[:search].present? ? TeamRepository.search(params[:search]) : TeamRepository.all
    else
      @teams = current_user.team ? [current_user.team] : []
    end
  end

  def new
    unless current_user.super_admin?
      redirect_to teams_path, alert: 'Chỉ Super Admin được tạo team'
      return
    end
    @team = Team.new
  end

  def create
    unless current_user.super_admin?
      redirect_to teams_path, alert: 'Not authorized'
      return
    end

    @team = TeamService.create_team(team_params)
    if @team.persisted?
      redirect_to teams_path, notice: 'Tạo team thành công.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless current_user.super_admin?
      redirect_to teams_path, alert: 'Chỉ Super Admin được sửa team'
      return
    end
  end

  def update
    unless current_user.super_admin?
      redirect_to teams_path, alert: 'Not authorized'
      return
    end

    if TeamService.update_team(@team.id, team_params)
      redirect_to teams_path, notice: 'Cập nhật team thành công.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.super_admin?
      redirect_to teams_path, alert: 'Chỉ Super Admin được xoá team'
      return
    end

    TeamService.destroy_team(@team.id)
    redirect_to teams_path, notice: 'Xoá team thành công.'
  end

  def manage_members
    unless current_user.super_admin? || current_user.admin?
      redirect_to teams_path, alert: 'Not authorized'
      return
    end

    unless @team
      redirect_to teams_path, alert: 'Team không tồn tại.'
      return
    end
    
    @team_members = @team.users
    @available_users = User.where(team_id: nil)
  end

  def add_member
    unless current_user.super_admin? || (current_user.admin? && current_user.team == @team)
      redirect_to teams_path, alert: 'Not authorized'
      return
    end

    # Lấy user_id từ params (cả từ form và từ button)
    user_id = params[:user_id]
    
    unless user_id
      redirect_to manage_members_team_path(@team), alert: 'Vui lòng chọn user'
      return
    end

    user = User.find(user_id)
    
    # Kiểm tra user có thuộc available users không (bảo mật thêm)
    available_user_ids = User.where(team_id: nil).pluck(:id)
    unless available_user_ids.include?(user.id)
      redirect_to manage_members_team_path(@team), alert: 'User không khả dụng'
      return
    end

    if user.update(team_id: @team.id)
      redirect_to manage_members_team_path(@team), notice: "Đã thêm #{user.name} vào team"
    else
      redirect_to manage_members_team_path(@team), alert: "Không thể thêm user: #{user.errors.full_messages.join(', ')}"
    end
  end

  def remove_member
    unless current_user.super_admin? || (current_user.admin? && current_user.team == @team)
      redirect_to teams_path, alert: 'Not authorized'
      return
    end

    user = User.find(params[:user_id])
    
    # QUAN TRỌNG: Không cho xóa chính mình
    if user == current_user
      redirect_to manage_members_team_path(@team), alert: 'Bạn không thể xóa chính mình khỏi team'
      return
    end

    # Kiểm tra xem user có thuộc team này không
    if user.team_id != @team.id
      redirect_to manage_members_team_path(@team), alert: 'User không thuộc team này'
      return
    end

    if user.update(team_id: nil)
      redirect_to manage_members_team_path(@team), notice: "Đã xoá #{user.name} khỏi team"
    else
      redirect_to manage_members_team_path(@team), alert: "Không thể xoá user: #{user.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_team
    @team = TeamRepository.find(params[:id])
  end

  def authorize_team_access
    # Chỉ admin mới được thực hiện các action quản lý team
    unless current_user&.super_admin?
      redirect_to teams_path, alert: 'Bạn không có quyền thực hiện hành động này.'
    end
  end

  def team_params
    params.require(:team).permit(:name, :description)
  end
end