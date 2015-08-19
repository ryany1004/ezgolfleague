class CreateTournamentDayResults < ActiveRecord::Migration
  def change
    create_table :tournament_day_results do |t|
      t.integer :tournament_day_id
      t.integer :user_id
      t.integer :user_primary_scorecard_id
      t.integer :flight_id
      t.integer :gross_score
      t.integer :net_score
      t.integer :back_nine_net_score
      t.timestamps null: false
    end
    
    add_index :tournament_day_results, :tournament_day_id
    add_index :tournament_day_results, :user_id
    add_index :tournament_day_results, :user_primary_scorecard_id
    add_index :tournament_day_results, :flight_id
  end
end