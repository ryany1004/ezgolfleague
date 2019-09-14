class Score < ApplicationRecord
  include Servable

  acts_as_paranoid

  belongs_to :scorecard, inverse_of: :scores, touch: true
  belongs_to :course_hole

  validates :strokes, inclusion: 0..30

  def unscored?
    strokes.blank? || strokes.zero? && net_strokes.zero?
  end

  def associated_text
    scorecard.tournament_day.scorecard_base_scoring_rule.associated_text_for_score(self)
  end

  def course_hole_number
    course_hole.hole_number.to_s
  end

  def course_hole_par
    course_hole.par.to_s
  end

  def display_score
    strokes
  end

  def course_hole_yards
    flight = scorecard.tournament_day.flight_for_player(scorecard.golf_outing.user)

    course_hole.yards_for_flight(flight) if flight.present?
  end

  def tee_group_name
    flight = scorecard.tournament_day.flight_for_player(scorecard.golf_outing.user)

    if flight.blank?
      nil
    else
      flight.course_tee_box.name
    end
  end
end
