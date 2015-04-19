class Flight < ActiveRecord::Base
  belongs_to :tournament, inverse_of: :flights
  has_many :payouts, -> { order(:sort_order) }, inverse_of: :flight, :dependent => :destroy
  has_and_belongs_to_many :users, inverse_of: :flights
  
end
