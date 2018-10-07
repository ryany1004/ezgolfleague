class AddKeepPlayOpenToTournamentDay < ActiveRecord::Migration[5.1]
  def change
  	add_column :tournament_days, :enter_scores_until_finalized, :boolean, default: false

  	TournamentDay.all.each do |d|
  		d.enter_scores_until_finalized = false
  		d.save
  	end
  end
end
