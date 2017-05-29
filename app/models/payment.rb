PAYMENT_METHOD_CREDIT_CARD = "Credit Card"

class Payment < ActiveRecord::Base
  belongs_to :user, inverse_of: :payments, touch: true
  belongs_to :tournament, inverse_of: :payments, touch: true
  belongs_to :league_season, inverse_of: :payments, touch: true
  belongs_to :contest, inverse_of: :payments, touch: true

  has_many :credits, class_name: "Payment", foreign_key: "payment_id", inverse_of: :original_payment
  belongs_to :original_payment, class_name: "Payment", foreign_key: "payment_id", inverse_of: :credits

  validates :user, presence: true
  validates :payment_amount, presence: true

  validate :has_tournament_or_league
  def has_tournament_or_league
    if tournament.blank? && league_season.blank? && contest.blank?
      errors.add(:tournament_id, "can't all be blank")
      errors.add(:league_season_id, "can't all be blank")
      errors.add(:contest_id, "can't all be blank")
    end
  end

  paginates_per 50

  def generated_description
    if !self.tournament.blank?
      if self.payment_amount < 0.0
        return "Dues for #{self.tournament.name}"
      else
        return "Payment for #{self.tournament.name}"
      end
    elsif !self.league_season.blank?
      if self.payment_amount < 0.0
        return "Dues for #{self.league_season.league.name} #{self.league_season.name}"
      else
        return "Payment for #{self.league_season.league.name} #{self.league_season.name}"
      end
    elsif !self.contest.blank?
      if self.payment_amount < 0.0
        return "Dues for #{self.contest.name} (#{self.contest.tournament_day.tournament.name})"
      else
        return "Payment for #{self.contest.name} (#{self.contest.tournament_day.tournament.name})"
      end
    else
      return self.payment_type
    end
  end

  def modifiable?
    if self.payment_source == PAYMENT_METHOD_CREDIT_CARD
      return false
    else
      return true
    end
  end

end
