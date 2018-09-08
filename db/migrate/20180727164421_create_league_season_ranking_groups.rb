class CreateLeagueSeasonRankingGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :league_season_ranking_groups do |t|
    	t.integer :league_season_id
    	t.string :name
      t.timestamps
      t.index ["league_season_id"], name: "index_league_season_id"
    end
  end
end
