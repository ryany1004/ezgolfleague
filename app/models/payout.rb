class Payout < ActiveRecord::Base
  belongs_to :flight, inverse_of: :payouts  
  has_one :payout_result, :dependent => :destroy
end
