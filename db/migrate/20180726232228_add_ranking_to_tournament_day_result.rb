class AddRankingToTournamentDayResult < ActiveRecord::Migration[5.1]
  def change
  	change_table :tournament_day_results do |t|
      t.integer :rank, default: 0
      t.string :name
    end
  end
end
