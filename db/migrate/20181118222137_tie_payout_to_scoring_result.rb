class TiePayoutToScoringResult < ActiveRecord::Migration[5.1]
  def change
  	add_reference :payouts, :scoring_rule, index: true
  end
end
