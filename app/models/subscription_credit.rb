class SubscriptionCredit < ApplicationRecord
  belongs_to :league_season

  validates :amount, presence: true

  def self.cost_per_golfer
    10
  end
  
end
