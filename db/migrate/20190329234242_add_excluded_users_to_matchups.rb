class AddExcludedUsersToMatchups < ActiveRecord::Migration[5.2]
  def change
  	add_column :league_season_team_tournament_day_matchups, :excluded_user_ids, :string
  end
end
