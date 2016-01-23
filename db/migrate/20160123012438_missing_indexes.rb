class MissingIndexes < ActiveRecord::Migration
  def change
    add_index :contests, :overall_winner_contest_result_id
    add_index :contests_users, :contest_id
    add_index :contests_users, :user_id
    add_index :golfer_teams_users, :golfer_team_id
    add_index :golfer_teams_users, :user_id
    add_index :league_seasons, :league_id
    add_index :payments, :league_season_id
    add_index :payouts, :user_id
    add_index :tournament_days, :tournament_id
    add_index :tournament_days, :course_id
    
  end
end