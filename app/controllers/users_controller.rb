class UsersController < ApplicationController
  layout 'admin'
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = params[:search].present? ? UserRepository.search(params[:search]) : UserRepository.all
  end

  def new
    @user = User.new
    @teams = TeamRepository.all
  end

  def create
    @user = UserService.create_user(user_params)
    if @user.persisted?
      redirect_to users_path, notice: 'Tạo user thành công.'
    else
      @teams = TeamRepository.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @teams = TeamRepository.all
  end

  def update
    if UserService.update_user(@user.id, user_params)
      redirect_to users_path, notice: 'Cập nhật user thành công.'
    else
      @teams = TeamRepository.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    UserService.destroy_user(@user.id)
    redirect_to users_path, notice: 'Xoá user thành công.'
  end

  private

  def set_user
    @user = UserRepository.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :avatar, :team_id)
  end
end