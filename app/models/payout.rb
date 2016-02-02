class Payout < ActiveRecord::Base
  belongs_to :flight, inverse_of: :payouts
  belongs_to :user  #TODO: REMOVE
  
  has_one :payout_result, :dependent => :destroy
end
