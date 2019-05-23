module Users
  module HandicapSupport
    def course_handicap_for_golf_outing(golf_outing, flight = nil)
      membership = league_membership_for_league(golf_outing.tournament_group.tournament_day.tournament.league)

      if membership.present? && membership.course_handicap.present?
        Rails.logger.info { "Handicap: Using Override Course Handicap: #{membership.course_handicap}" }

        membership.course_handicap
      else
        Rails.logger.info { "Handicap: Using Index Derived Handicap" }

        index_derived_handicap(flight, golf_outing)
      end
    end

    def index_derived_handicap(flight, golf_outing)
      unless flight.blank?
        course_tee_box = flight.course_tee_box
      else
        course_tee_box = golf_outing.course_tee_box
      end

      return nil if handicap_index.blank? || course_tee_box.blank? || golf_outing.blank? # this will fail if the user is not flighted

      if golf_outing.tournament_group.tournament_day.scorecard_base_scoring_rule.course_holes.count == 9
        nine_hole_handicap(golf_outing.tournament_group.tournament_day.course, course_tee_box)
      else
        standard_handicap(golf_outing.tournament_group.tournament_day.course, course_tee_box)
      end
    end

    # http://www.usga.org/handicapFAQ/handicap_answer.asp?FAQidx=4
    def standard_handicap(selected_course, course_tee_box)
      handicap = (handicap_index.to_f * (course_tee_box.slope.to_f / 113.0)).round

      Rails.logger.info { "U: #{id} HI: #{handicap_index.to_f} Slope: #{course_tee_box.slope.to_f} Course Tee Box: #{course_tee_box.id}" }
      Rails.logger.info { "Handicap: #{handicap}" }

      handicap
    end

    # http://www.mygolfinstructor.com/instruction/rules-of-golf/tips/calculate-9-hole-handicap-18-hole-handicap/569/
    def nine_hole_handicap(selected_course, course_tee_box)
      handicap = ((handicap_index.to_f / 2.0) * (course_tee_box.slope.to_f / 113.0)).round

      Rails.logger.info { "U: #{id} HI: #{handicap_index.to_f} Slope: #{course_tee_box.slope.to_f} Course Tee Box: #{course_tee_box.id}" }
      Rails.logger.info { "9 Hole Handicap: #{handicap}" }

      handicap
    end
  end
end
