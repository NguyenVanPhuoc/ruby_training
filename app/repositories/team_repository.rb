class TeamRepository
  def self.search(keyword)
    Team.where('name LIKE ?', "%#{keyword}%")
  end

  def self.all
    Team.all
  end

  def self.find(id)
    Team.find(id)
  end

  def self.destroy(id)
    Team.find(id).destroy
  end
end