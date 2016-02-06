class AdjustedScoresOnResults < ActiveRecord::Migration
  def change
    add_column :tournament_day_results, :adjusted_score, :integer, :default => 0
    
    TournamentDayResult.all.each do |t|
      t.adjusted_score = 0
      t.save
    end
  end
end
