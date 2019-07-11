module ScoringRuleScorecards
  class ThreeBestBallsOfFourScorecard < ScoringRuleScorecards::BestBallScorecard
    NUMBER_OF_SCORES_TO_USE = 3

    def name(shorten_for_print = false)
      if should_use_handicap
        if shorten_for_print
          'Net'
        else
          'Three Best Balls of Four Net'
        end
      else
        if shorten_for_print
          'Gross'
        else
          'Three Best Balls of Four Gross'
        end
      end
    end

    def score_for_scores(comparable_scores, hole)
      return 0 if comparable_scores.blank?

      comparable_scores.reject!(&:zero?)

      sorted_scores = comparable_scores.sort! { |x, y| x <=> y }
      best_scores = sorted_scores[0, NUMBER_OF_SCORES_TO_USE]
      summed_score = best_scores.inject(:+)

      if @scoring_rule.should_add_par? && comparable_scores.count < NUMBER_OF_SCORES_TO_USE
        summed_score += hole.par
      end

      [summed_score, 0].max # you cannot have a negative score here
    end
  end
end
