class AddNoteAboutAggregateResult < ActiveRecord::Migration[5.1]
  def change
  	add_column :tournament_day_results, :aggregated_result, :boolean, default: false
  	add_index :tournament_day_results, :aggregated_result

  	TournamentDayResult.all.each do |d|
  		d.aggregated_result = false
  		d.save
  	end
  end
end
