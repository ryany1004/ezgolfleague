class CreateTournamentGroups < ActiveRecord::Migration
  def change
    create_table :tournament_groups do |t|
      t.integer :tournament_id, index: true
      t.datetime :tee_time_at
      t.timestamps null: false
    end
  end
end
