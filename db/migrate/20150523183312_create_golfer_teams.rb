class CreateGolferTeams < ActiveRecord::Migration
  def change
    create_table :golfer_teams do |t|
      t.integer :tournament_id
      t.integer :max_players, :default => 2
      t.timestamps null: false
    end
    
    create_table "golfer_teams_users", id: false, force: :cascade do |t|
      t.integer "golfer_team_id"
      t.integer "user_id"
    end
  end
end
