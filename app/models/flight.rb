class Flight < ApplicationRecord
  belongs_to :tournament_day, inverse_of: :flights, touch: true
  belongs_to :course_tee_box
  has_one :league_season_scoring_group, inverse_of: :flight
  has_many :payouts, -> { order(:sort_order, "amount DESC, points DESC") }, inverse_of: :flight, :dependent => :destroy
  has_many :payout_results, -> { order("amount DESC, points DESC") }, inverse_of: :flight, :dependent => :destroy
  has_many :tournament_day_results, inverse_of: :flight, :dependent => :destroy
  has_and_belongs_to_many :users, inverse_of: :flights

  validates :flight_number, presence: true
  validates :lower_bound, presence: true
  validates :upper_bound, presence: true
  validates :course_tee_box, presence: true

  validate :bounds_are_correct
  def bounds_are_correct
    if upper_bound.blank? || lower_bound.blank?
      errors.add(:upper_bound, "cannot validate an empty value")
      errors.add(:lower_bound, "cannot validate an empty value")

      return
    end

    if upper_bound >= 0 and lower_bound >= 0 #special case for imported data
      if upper_bound <= lower_bound
        errors.add(:upper_bound, "can't be less than or equal to lower bound")
      end

      if lower_bound >= upper_bound
        errors.add(:lower_bound, "can't be greater than or equal to upper bound")
      end
    end
  end

  validate :does_not_overlap
  def does_not_overlap
    if upper_bound.blank? || lower_bound.blank?
      errors.add(:upper_bound, "cannot validate an empty value")
      errors.add(:lower_bound, "cannot validate an empty value")

      return
    end

    if upper_bound >= 0 and lower_bound >= 0 #special case for imported data
      other_flights = self.tournament_day.flights.where("id != ?", self.id)

      other_flights.each do |f|
        if lower_bound.between?(f.lower_bound, f.upper_bound)
          errors.add(:lower_bound, "can't be in inside the range of an existing flight for this tournament")
        end

        if upper_bound.between?(f.lower_bound, f.upper_bound)
          errors.add(:upper_bound, "can't be in inside the range of an existing flight for this tournament")
        end
      end
    end
  end

  def display_name(long_flight_name = false)
    if self.league_season_scoring_group.blank?
      if long_flight_name
        "Flight #{flight_number}"
      else
        flight_number.to_s
      end
    else
      league_season_scoring_group.name
    end
  end

end
