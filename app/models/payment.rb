class Payment < ActiveRecord::Base
  belongs_to :user, inverse_of: :payments
  belongs_to :tournament, inverse_of: :payments
  belongs_to :league, inverse_of: :payments
  
  
  
end
