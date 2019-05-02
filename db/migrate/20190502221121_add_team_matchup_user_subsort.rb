class AddTeamMatchupUserSubsort < ActiveRecord::Migration[5.2]
  def change
    add_column :league_season_team_tournament_day_matchups, :team_a_final_sort, :string
    add_column :league_season_team_tournament_day_matchups, :team_b_final_sort, :string
  end
end
