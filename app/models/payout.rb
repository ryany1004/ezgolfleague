class Payout < ActiveRecord::Base
  belongs_to :flight, inverse_of: :payouts
  has_many :payout_results, :dependent => :destroy

  validates :flight, presence: true
end
