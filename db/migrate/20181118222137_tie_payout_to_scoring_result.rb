class TiePayoutToScoringResult < ActiveRecord::Migration[5.1]
  def change
  	add_reference :payouts, :scoring_rule, index: true

  	Payout.all.each do |p|
  		d = p.flight.tournament_day

  		unless d.blank?
  			p.scoring_rule = d.scoring_rules.first unless d.scoring_rules.blank?
  			p.save
  		end
  	end
  end
end
