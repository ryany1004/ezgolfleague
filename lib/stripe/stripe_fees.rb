module Stripe
  STRIPE_FIXED_AMOUNT = 0.3
  STRIPE_PERCENT_AMOUNT = 0.029
  
  class StripeFees
    
    def self.fees_for_transaction_amount(amount)
      if amount.blank?
        return 0
      end
      
      return ((amount + STRIPE_FIXED_AMOUNT) / (1 - STRIPE_PERCENT_AMOUNT) - amount)
    end
    
  end
end