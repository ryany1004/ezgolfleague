class PayoutResult < ActiveRecord::Base
  belongs_to :payout, inverse_of: :payout_result
  belongs_to :flight, inverse_of: :payout_results
  belongs_to :user, inverse_of: :payout_results
  belongs_to :tournament_day, inverse_of: :payout_results
end
