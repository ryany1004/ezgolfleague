class SubscriptionCredit < ApplicationRecord
  scope :used, -> { where("tournaments_remaining = 0") }
  scope :unused, -> { where("tournaments_remaining > 0") }

  belongs_to :league_season
  has_many :tournaments

  validates :amount, presence: true

  def self.cost_per_golfer
    5
  end
end
