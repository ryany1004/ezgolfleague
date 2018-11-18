class Payout < ApplicationRecord
  belongs_to :flight, inverse_of: :payouts, touch: true
  belongs_to :scoring_rule, inverse_of: :payouts, touch: true
  has_many :payout_results, inverse_of: :payout, dependent: :destroy

  validates :flight, presence: true
end
