# used in the match play scorecard only

module HandicapComputer
  class MatchPlayHandicapComputer < BaseHandicapComputer
    def displayable_handicap_allowance(user:)
      match_play_handicap_allowance(user: user)
    end

    def match_play_handicap_allowance(user:)
      user_golf_outing = tournament_day.golf_outing_for_player(user)
      return nil if user_golf_outing.blank?

      user_course_handicap = course_handicap_for_game_type(user_golf_outing)

      opponent = @scoring_rule.opponent_for_user(user)
      opponent_golf_outing = tournament_day.golf_outing_for_player(opponent)
      return nil if opponent_golf_outing.blank?

      opponent_course_handicap = course_handicap_for_game_type(opponent_golf_outing)

      allowance = []
      if user_course_handicap > opponent_course_handicap
        baseline_handicap = 0

        baseline_handicap = user_course_handicap - opponent_course_handicap

        Rails.logger.debug { "MatchPlayHandicapComputer Baseline: #{baseline_handicap} from user #{user_course_handicap} and opponent #{opponent_course_handicap}" }

        if user_golf_outing.course_tee_box.tee_box_gender == 'Men'
          sorted_course_holes_by_handicap = tournament_day.scorecard_base_scoring_rule.course_holes.reorder('mens_handicap')
        else
          sorted_course_holes_by_handicap = tournament_day.scorecard_base_scoring_rule.course_holes.reorder('womens_handicap')
        end

        while baseline_handicap.positive? do
          sorted_course_holes_by_handicap.each do |hole|
            existing_hole = nil

            allowance.each do |a|
              existing_hole = a if hole == a[:course_hole]
            end

            if existing_hole.blank?
              existing_hole = { course_hole: hole, strokes: 0 }
              allowance << existing_hole
            end

            if baseline_handicap.positive?
              existing_hole[:strokes] = existing_hole[:strokes] + 1
              baseline_handicap -= 1
            end
          end
        end
      end

      allowance
    end
  end
end
