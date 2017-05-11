class SubscriptionCredit < ActiveRecord::Base
  scope :used, -> { where("tournaments_remaining = 0") }
  scope :unused, -> { where("tournaments_remaining > 0") }

  belongs_to :league
  has_many :tournaments

  validates :amount, presence: true

  def self.update_remaining_count
    #for each league, look at tournaments that are completed but do not have a subscription credit attached
    #attach and update counts
  end
end
