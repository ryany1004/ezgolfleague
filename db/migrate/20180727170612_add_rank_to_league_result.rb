class AddRankToLeagueResult < ActiveRecord::Migration[5.1]
  def change
   	change_table :league_season_rankings do |t|
      t.integer :rank, default: 0
    end
  end
end
