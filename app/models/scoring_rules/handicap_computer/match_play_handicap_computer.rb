module HandicapComputer
	class MatchPlayHandicapComputer < BaseHandicapComputer

    def handicap_allowance(user:)
      user_golf_outing = self.tournament_day.golf_outing_for_player(user)
      user_course_handicap = self.course_handicap_for_game_type(user_golf_outing)

      opponent = @scoring_rule.opponent_for_user(user)
      opponent_golf_outing = self.tournament_day.golf_outing_for_player(opponent)
      opponent_course_handicap = self.course_handicap_for_game_type(opponent_golf_outing)

      allowance = []
      if user_course_handicap > opponent_course_handicap
        baseline_handicap = 0

        baseline_handicap = user_course_handicap - opponent_course_handicap

        if user_golf_outing.course_tee_box.tee_box_gender == "Men"
          sorted_course_holes_by_handicap = self.tournament_day.course.course_holes.reorder("mens_handicap")
        else
          sorted_course_holes_by_handicap = self.tournament_day.course.course_holes.reorder("womens_handicap")
        end

        while baseline_handicap > 0 do
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

            if baseline_handicap > 0
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