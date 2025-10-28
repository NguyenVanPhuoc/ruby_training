class AddDescriptionToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :description, :text
  end
end
