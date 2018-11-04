class RenameGolferTeams < ActiveRecord::Migration[5.1]
  def change
    remove_index :index_golfer_teams_on_parent_team_id
    remove_index :index_golfer_teams_on_tournament_day_id
    remove_index :index_golfer_teams_tournament_group_id

    remove_index :index_golfer_teams_users_on_golfer_team_id
    remove_index :index_golfer_teams_users_on_user_id

    remove_index :index_game_type_metadata_on_golfer_team_id

    rename_table :golfer_teams, :tournament_teams
    rename_table :golfer_teams_users, :tournament_teams_users
    rename_column :tournament_teams_users, :golfer_team_id, :tournament_team_id
    rename_column :game_type_metadata, :golfer_team_id, :tournament_team_id

    add_index :tournament_teams, :parent_team_id
    add_index :tournament_teams, :tournament_day_id
    add_index :tournament_teams, :tournament_group_id

    add_index :tournament_teams_users, :tournament_team_id
    add_index :tournament_teams_users, :user_id

    add_index :game_type_metadata, :tournament_team_id
  end
end