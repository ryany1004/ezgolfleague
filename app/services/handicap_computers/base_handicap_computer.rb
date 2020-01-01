module HandicapComputers
  class BaseHandicapComputer
    def initialize(scoring_rule)
      @scoring_rule = scoring_rule
    end

    def tournament_day
      @scoring_rule.tournament_day
    end

    def displayable_handicap_allowance(user:)
      handicap_allowance(user: user)
    end

    def match_play_handicap_allowance(user:)
      handicap_allowance(user: user)
    end

    def handicap_allowance(user:)
      golf_outing = tournament_day.golf_outing_for_player(user)
      return nil if golf_outing.blank? # did not play

      course_handicap = course_handicap_for_game_type(golf_outing)
      course_handicap = course_handicap.round

      allowance = Rails.cache.fetch("golf_outing#{golf_outing.id}-#{golf_outing.updated_at.to_i}", expires_in: 15.minute, race_condition_ttl: 10) do
        return nil if golf_outing.course_tee_box.blank?

        Rails.logger.debug { "BaseHandicapComputer Course Handicap: #{course_handicap}" }

        if golf_outing.course_tee_box.tee_box_gender == 'Men'
          sorted_course_holes_by_handicap = tournament_day.scorecard_base_scoring_rule.course_holes.reorder('mens_handicap')
        else
          sorted_course_holes_by_handicap = tournament_day.scorecard_base_scoring_rule.course_holes.reorder('womens_handicap')
        end

        if sorted_course_holes_by_handicap.count.positive? && course_handicap.present?
          allowance = []

          while course_handicap != 0
            sorted_course_holes_by_handicap.each do |hole|
              existing_hole = nil

              allowance.each do |a|
                existing_hole = a if hole == a[:course_hole]
              end

              if existing_hole.blank?
                existing_hole = { course_hole: hole, strokes: 0 }
                allowance << existing_hole
              end

              if course_handicap.positive?
                existing_hole[:strokes] = existing_hole[:strokes] + 1

                course_handicap -= 1
              elsif course_handicap.negative?
                existing_hole[:strokes] = existing_hole[:strokes] - 1

                course_handicap += 1
              end
            end

            Rails.logger.debug { "CH: #{course_handicap}" }
          end

          allowance
        end
      end

      allowance
    end

    def team_handicap_for_user(user)
      nil
    end

    def course_handicap_for_game_type(golf_outing)
      golf_outing.course_handicap
    end
  end
end
