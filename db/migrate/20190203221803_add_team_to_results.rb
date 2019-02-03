class AddTeamToResults < ActiveRecord::Migration[5.2]
  def change
  	add_column :tournament_day_results, :league_season_team_id, :bigint

  	add_index :tournament_day_results, :league_season_team_id
  end
end
