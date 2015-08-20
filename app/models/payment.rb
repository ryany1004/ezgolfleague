PAYMENT_METHOD_CREDIT_CARD = "Credit Card"

class Payment < ActiveRecord::Base
  belongs_to :user, inverse_of: :payments
  belongs_to :tournament, inverse_of: :payments
  belongs_to :league, inverse_of: :payments
  belongs_to :contest, inverse_of: :payments
  
  validates :user, presence: true
  validates :payment_amount, presence: true
  
  validate :has_tournament_or_league
  def has_tournament_or_league  
    if tournament.blank? && league.blank? && contest.blank?
      errors.add(:tournament_id, "can't all be blank")
      errors.add(:league_id, "can't all be blank")
      errors.add(:contest_id, "can't all be blank")
    end
  end
  
  paginates_per 50
  
  def payment_details
    if !self.tournament.blank?
      if self.payment_amount < 0.0
        return "Dues for #{self.tournament.name}"
      else
        return "Payment for #{self.tournament.name}"
      end
    elsif !self.league.blank?
      if self.payment_amount < 0.0
        return "Dues for #{self.league.name}"
      else
        return "Payment for #{self.league.name}"
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
  
  def self.balance_for_user(u)
    total_balance = 0
    
    u.payments.each do |p|
      total_balance = total_balance + p.payment_amount
    end
    
    return total_balance
  end
  
end
