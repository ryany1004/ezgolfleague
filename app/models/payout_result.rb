class PayoutResult < ApplicationRecord
	acts_as_paranoid
	
  belongs_to :payout, inverse_of: :payout_results, touch: true
  belongs_to :flight, inverse_of: :payout_results, touch: true
  belongs_to :user, inverse_of: :payout_results
  belongs_to :tournament_day, inverse_of: :payout_results, touch: true #TEAM: REMOVE
  belongs_to :scoring_rule, inverse_of: :payout_results, touch: true
end
