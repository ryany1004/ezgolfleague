module HandicapComputer
	class BaseHandicapComputer
		def initialize(scoring_rule)
			@scoring_rule = scoring_rule
		end

		def tournament_day
			@scoring_rule.tournament_day
		end

    def handicap_allowance(user:)
      golf_outing = self.tournament_day.golf_outing_for_player(user)
      return nil if golf_outing.blank? #did not play

      course_handicap = self.course_handicap_for_game_type(golf_outing)

      allowance = Rails.cache.fetch("golf_outing#{golf_outing.id}-#{golf_outing.updated_at.to_i}", expires_in: 15.minute, race_condition_ttl: 10) do
        return nil if golf_outing.course_tee_box.blank?

        Rails.logger.debug { "BaseHandicapComputer Course Handicap: #{course_handicap}" }

        if golf_outing.course_tee_box.tee_box_gender == "Men"
          sorted_course_holes_by_handicap = self.tournament_day.scorecard_base_scoring_rule.course_holes.reorder("mens_handicap")
        else
          sorted_course_holes_by_handicap = self.tournament_day.scorecard_base_scoring_rule.course_holes.reorder("womens_handicap")
        end

        if sorted_course_holes_by_handicap.count > 0 && !course_handicap.blank?
          allowance = []
          while course_handicap > 0 do
            sorted_course_holes_by_handicap.each do |hole|
              existing_hole = nil

              allowance.each do |a|
                if hole == a[:course_hole]
                  existing_hole = a
                end
              end

              if existing_hole.blank?
                existing_hole = {course_hole: hole, strokes: 0}
                allowance << existing_hole
              end

              if course_handicap > 0
                existing_hole[:strokes] = existing_hole[:strokes] + 1
                course_handicap = course_handicap - 1
              end
            end
          end

          allowance
        else
          nil
        end
      end

      allowance
    end
	
    def course_handicap_for_game_type(golf_outing)
      golf_outing.course_handicap
    end
  end
end