class CreateLeagueSeasonTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :league_season_teams do |t|
    	t.bigint :league_season_id
    	t.string :name
    	t.integer :rank, default: 0
      t.timestamps
    end

    add_index :league_season_teams, :league_season_id

    change_table :league_seasons do |t|
    	t.integer :season_type_raw, default: 0
    end
  end
end
