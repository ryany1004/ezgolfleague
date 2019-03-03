class MoveMatchupsToTd < ActiveRecord::Migration[5.2]
  def change
  	add_column :league_season_team_tournament_day_matchups, :tournament_day_id, :bigint
  	remove_column :league_season_team_tournament_day_matchups, :tournament_group_id

  	add_index :league_season_team_tournament_day_matchups, :tournament_day_id, name: "tournament_day_index"
  end
end
