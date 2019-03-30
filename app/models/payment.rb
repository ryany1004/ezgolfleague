PAYMENT_METHOD_CREDIT_CARD = "Credit Card"

class Payment < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :user, inverse_of: :payments

  belongs_to :scoring_rule, inverse_of: :payments, optional: true, touch: true
  belongs_to :league_season, inverse_of: :payments, optional: true, touch: true

  has_many :credits, class_name: "Payment", foreign_key: "payment_id", inverse_of: :original_payment
  belongs_to :original_payment, class_name: "Payment", foreign_key: "payment_id", inverse_of: :credits, optional: true

  validates :user, presence: true
  validates :payment_amount, presence: true

  validate :has_scoring_rule_or_league
  def has_scoring_rule_or_league
    if scoring_rule.blank? && league_season.blank?
      errors.add(:scoring_rule_id, "can't all be blank")
      errors.add(:league_season_id, "can't all be blank")
    end
  end

  paginates_per 50

  def tournament
    self.scoring_rule.tournament_day.tournament
  end

  def generated_description
    if !self.scoring_rule.blank?
      if self.payment_amount < 0.0
        "Dues for #{self.tournament.name}"
      else
        "Payment for #{self.tournament.name}"
      end
    elsif !self.league_season.blank?
      if self.payment_amount < 0.0
        "Dues for #{self.league_season.league.name} #{self.league_season.name}"
      else
        "Payment for #{self.league_season.league.name} #{self.league_season.name}"
      end
    else
      self.payment_type
    end
  end

  def modifiable?
    if self.payment_source == PAYMENT_METHOD_CREDIT_CARD
      false
    else
      true
    end
  end

end
