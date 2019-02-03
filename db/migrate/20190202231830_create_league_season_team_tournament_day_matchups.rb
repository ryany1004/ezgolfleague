class CreateLeagueSeasonTeamTournamentDayMatchups < ActiveRecord::Migration[5.2]
  def change
    create_table :league_season_team_tournament_day_matchups do |t|
    	t.bigint :tournament_group_id
    	t.bigint :league_season_team_a_id
    	t.bigint :league_season_team_b_id
      t.timestamps
    end
  end
end
