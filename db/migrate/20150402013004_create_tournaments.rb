class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.integer :league_id
      t.integer :course_id
      t.string :name
      t.datetime :tournament_at
      t.datetime :signup_opens_at
      t.datetime :signup_closes_at
      t.integer :max_players
      t.timestamps null: false
    end
  end
end
