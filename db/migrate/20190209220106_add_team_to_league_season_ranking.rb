class AddTeamToLeagueSeasonRanking < ActiveRecord::Migration[5.2]
  def change
  	add_column :league_season_rankings, :league_season_team_id, :bigint

  	add_index :league_season_rankings, :league_season_team_id
  end
end
