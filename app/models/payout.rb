class Payout < ApplicationRecord
  belongs_to :flight, inverse_of: :payouts, optional: true, touch: true
  belongs_to :scoring_rule, inverse_of: :payouts, touch: true
  has_many :payout_results, inverse_of: :payout, dependent: :destroy

  validates :scoring_rule, presence: true
  validates :flight, presence: true, unless: Proc.new { |a| !a.scoring_rule.flight_based_payouts? }
  validates :amount, presence: true

  def to_s
    "#{id} - Flight #{flight&.id} #{amount} #{points}"
  end

  def apply_as_duplicates?
  	self.scoring_rule.tournament_day.tournament.is_league_teams? && self.amount.zero?
  end
end
