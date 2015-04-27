class Payout < ActiveRecord::Base
  belongs_to :flight, inverse_of: :payouts
  belongs_to :user, inverse_of: :payouts
end
