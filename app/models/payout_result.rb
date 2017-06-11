class PayoutResult < ApplicationRecord
  belongs_to :payout, inverse_of: :payout_results, touch: true
  belongs_to :flight, inverse_of: :payout_results, touch: true
  belongs_to :user, inverse_of: :payout_results, touch: true
  belongs_to :tournament_day, inverse_of: :payout_results, touch: true
end
