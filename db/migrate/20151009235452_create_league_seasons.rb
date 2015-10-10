class CreateLeagueSeasons < ActiveRecord::Migration
  def change
    create_table :league_seasons do |t|
      t.integer :league_id
      t.string :name
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps null: false
    end
  end
end
