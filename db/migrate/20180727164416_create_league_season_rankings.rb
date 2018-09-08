class CreateLeagueSeasonRankings < ActiveRecord::Migration[5.1]
  def change
    create_table :league_season_rankings do |t|
    	t.integer :league_season_ranking_group_id
    	t.integer :user_id
    	t.integer :points, default: 0
    	t.decimal :payouts, default: 0
      t.timestamps
      t.index ["user_id"], name: "index_league_season_ranking_group_user_id"
      t.index ["league_season_ranking_group_id"], name: "index_league_season_ranking_group_id"
    end
  end
end
