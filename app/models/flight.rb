class Flight < ActiveRecord::Base
  belongs_to :tournament, inverse_of: :flights
  has_many :payouts, -> { order(:sort_order) }, inverse_of: :flight, :dependent => :destroy
  has_and_belongs_to_many :users, inverse_of: :flights
  
  validates :flight_number, presence: true
  validates :lower_bound, presence: true
  validates :upper_bound, presence: true
  validates :flight_number, uniqueness: { scope: :tournament_id }

  validate :bounds_are_correct
  def bounds_are_correct
    if upper_bound <= lower_bound
      errors.add(:upper_bound, "can't be less than or equal to lower bound")
    end
    
    if lower_bound >= upper_bound
      errors.add(:lower_bound, "can't be greater than or equal to upper bound")
    end
  end
  
  validate :does_not_overlap
  def does_not_overlap
    other_flights = self.tournament.flights.where("id != ?", self.id)
    
    other_flights.each do |f|
      if lower_bound.between?(f.lower_bound, f.upper_bound)
        errors.add(:lower_bound, "can't be in inside the range of an existing flight")
      end
      
      if upper_bound.between?(f.lower_bound, f.upper_bound)
        errors.add(:upper_bound, "can't be in inside the range of an existing flight")
      end
    end
  end
  
end
