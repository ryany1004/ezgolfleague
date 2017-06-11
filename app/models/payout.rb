class Payout < ApplicationRecord
  belongs_to :flight, inverse_of: :payouts, touch: true
  has_many :payout_results, :dependent => :destroy

  validates :flight, presence: true
end
