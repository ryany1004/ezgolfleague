class AddSubRank < ActiveRecord::Migration[5.1]
  def change
  	add_column :tournament_day_results, :sort_rank, :integer
  	add_index :tournament_day_results, :sort_rank

  	TournamentDayResult.all.each do |r|
  		r.sort_rank = r.rank
  		r.save
  	end
  end
end
