class SubscriptionCredit < ApplicationRecord
  belongs_to :league_season

  validates :amount, presence: true

  after_create :send_to_drip

  def self.cost_per_golfer
    10
  end

  def send_to_drip
    rep = self.drip_representation

    email = self.league_season.league.league_admins.first.email
    response = DRIP_CLIENT.create_or_update_order(email, rep)

    response
  end
  
  def drip_representation
    rep = {}

    rep[:provider] = "EZ Golf League"
    rep[:upstream_id] = self.id
    rep[:occurred_at] = self.created_at.iso8601
    rep[:amount] = self.amount.to_i * 100
    rep[:tax] = 0
    rep[:financial_state] = "paid"
    rep[:currency_code] = "USD"
    rep[:fulfillment_state] = "fulfilled"

    item = {
      upstream_id: self.id,
      name: "Subscription Credits",
      price: SubscriptionCredit.cost_per_golfer * 100,
      amount: self.amount.to_i * 100,
      quantity: self.golfer_count,
    }
    rep[:items] = [item]

    rep
  end

end
