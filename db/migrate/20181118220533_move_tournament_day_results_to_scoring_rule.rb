class MoveTournamentDayResultsToScoringRule < ActiveRecord::Migration[5.1]
  def change
  	add_reference :tournament_day_results, :scoring_rule, index: true

  	TournamentDayResult.all.each do |p|
  		d = TournamentDay.where(id: p.tournament_day_id).first

  		p.scoring_rule = d.scoring_rules.first unless d.blank? || d.scoring_rules.first.blank?
  		p.save
  	end

  	remove_column :tournament_day_results, :tournament_day_id
  end
end
