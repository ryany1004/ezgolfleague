class MovePayoutsToScoringRules < ActiveRecord::Migration[5.1]
  def change
  	PayoutResult.all.each do |p|
  		d = TournamentDay.where(id: p.tournament_day_id).first

  		p.scoring_rule = d&.scoring_rules&.first
  		p.save
  	end

  	remove_column :payout_results, :tournament_day_id
  end
end
