PAYMENT_METHOD_CREDIT_CARD = "Credit Card"

class Payment < ActiveRecord::Base
  belongs_to :user, inverse_of: :payments
  belongs_to :tournament, inverse_of: :payments
  belongs_to :league, inverse_of: :payments
  
  validates :user, presence: true
  validates :payment_amount, presence: true
  
  validate :has_tournament_or_league
  def has_tournament_or_league  
    if tournament.blank? && league.blank?
      errors.add(:tournament_id, "can't both be blank")
      errors.add(:league_id, "can't both be blank")
    end
  end
  
  paginates_per 50
  
  def payment_details
    if !self.tournament.blank?
      return "Payment for #{self.tournament.name}"
    elsif !self.league.blank?
      return "Dues for #{self.league.name}"
    else
      return self.payment_type
    end
  end
  
  def modifiable?
    if self.payment_method == PAYMENT_METHOD_CREDIT_CARD
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
