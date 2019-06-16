module ScoringComputer
  class StablefordScoringComputer < StrokePlayScoringComputer
    def rank_results_sort_descending
      true
    end

    def generate_tournament_day_result(user:, scorecard: nil)
      scorecard = @scoring_rule.stableford_scorecard_for_user(user: user)
      return nil if scorecard.blank? || scorecard.scores.blank?

      if scorecard.gross_score.positive?
        result_name = Users::ResultName.result_name_for_user(user, @scoring_rule)

        flight = tournament_day.flight_for_player(user)
        flight = tournament_day.assign_user_to_flight(user: user) if flight.blank?

        gross_score = scorecard.gross_score
        net_score = scorecard.net_score

        front_nine_gross_score = 0
        front_nine_net_score = 0
        back_nine_gross_score = 0
        back_nine_net_score = 0

        scorecard.scores.each do |score|
          score.net_strokes = score.strokes

          front_nine_gross_score += score.strokes if front_nine_hole_numbers.include? score.course_hole.hole_number
          front_nine_net_score += score.net_strokes if front_nine_hole_numbers.include? score.course_hole.hole_number

          back_nine_gross_score += score.strokes if back_nine_hole_numbers.include? score.course_hole.hole_number
          back_nine_net_score += score.net_strokes if back_nine_hole_numbers.include? score.course_hole.hole_number
        end

        result = @scoring_rule.tournament_day_results.find_or_create_by(user: user) # TODO: create_or_find_by

        result.name = result_name
        result.primary_scorecard = tournament_day.primary_scorecard_for_user(user)
        result.flight = flight
        result.gross_score = gross_score
        result.net_score = net_score
        result.adjusted_score = 0
        result.front_nine_gross_score = front_nine_gross_score
        result.front_nine_net_score = front_nine_net_score
        result.back_nine_gross_score = back_nine_gross_score
        result.back_nine_net_score = back_nine_net_score
        result.par_related_net_score = net_score
        result.par_related_gross_score = gross_score

        result.save

        Rails.logger.debug { "Writing tournament day result #{result}" }

        result
      else
        Rails.logger.debug { "Gross Score was #{gross_score}. Returning nil for tournament day result." }

        destroy_user_results(user)

        nil
      end
    end
  end
end
