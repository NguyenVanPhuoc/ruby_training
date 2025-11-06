class TeamService
  def self.create_team(params)
    Team.create(params)
  end

  def self.update_team(id, params)
    team = TeamRepository.find(id)
    team.update(params)
    team
  end

  def self.destroy_team(id)
    TeamRepository.find(id).destroy
  end
end