class Score < ApplicationRecord
  include Servable

  acts_as_paranoid

  belongs_to :scorecard, inverse_of: :scores, touch: true
  belongs_to :course_hole

  validates :strokes, inclusion: 0..30

  def associated_text
    self.scorecard.tournament_day.scorecard_base_scoring_rule.associated_text_for_score(self)
  end

  def course_hole_number
    self.course_hole.hole_number.to_s
  end

  def course_hole_par
    self.course_hole.par.to_s
  end

  def course_hole_yards
    flight = self.scorecard.tournament_day.flight_for_player(self.scorecard.golf_outing.user)

    self.course_hole.yards_for_flight(flight) unless flight.blank?
  end

  def tee_group_name
    flight = self.scorecard.tournament_day.flight_for_player(self.scorecard.golf_outing.user)

    if flight.blank?
      nil
    else
      flight.course_tee_box.name
    end
  end
end
