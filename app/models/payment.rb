class Payment < ActiveRecord::Base
  belongs_to :user, inverse_of: :payments
  belongs_to :tournament, inverse_of: :payments
  belongs_to :league, inverse_of: :payments
  
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
  
end
