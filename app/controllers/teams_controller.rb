class TeamsController < ApplicationController
  layout 'admin'  # Sử dụng admin layout
  before_action :set_team, only: [:edit, :update, :destroy]

  def index
    @teams = params[:search].present? ? TeamRepository.search(params[:search]) : TeamRepository.all
  end

  def new
    @team = Team.new
  end

  def create
    @team = TeamService.create_team(team_params)
    if @team.persisted?
      redirect_to teams_path, notice: 'Tạo team thành công.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if TeamService.update_team(@team.id, team_params)
      redirect_to teams_path, notice: 'Cập nhật team thành công.'
    else
      render :edit
    end
  end

  def destroy
    TeamService.destroy_team(@team.id)
    redirect_to teams_path, notice: 'Xoá team thành công.'
  end

  private

  def set_team
    @team = TeamRepository.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end