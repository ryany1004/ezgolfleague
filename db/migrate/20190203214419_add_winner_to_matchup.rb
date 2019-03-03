class AddWinnerToMatchup < ActiveRecord::Migration[5.2]
  def change
  	add_column :league_season_team_tournament_day_matchups, :league_team_winner_id, :bigint

  	add_index :league_season_team_tournament_day_matchups, :league_team_winner_id, name: "league_team_winner_id_index"
  	add_index :league_season_team_tournament_day_matchups, :league_season_team_a_id, name: "league_season_team_a_id_index"
  	add_index :league_season_team_tournament_day_matchups, :league_season_team_a_id, name: "league_season_team_b_id_index"
  end
end
