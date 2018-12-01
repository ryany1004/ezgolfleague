class RenameGolferTeams < ActiveRecord::Migration[5.1]
  def change
  	remove_column :golfer_teams, :tournament_day_id
  	rename_table :golfer_teams, :daily_teams

  	rename_column :game_type_metadata, :golfer_team_id, :daily_team_id

  	rename_table :golfer_teams_users, :daily_teams_users
  	rename_column :daily_teams_users, :golfer_team_id, :daily_team_id
  end
end
