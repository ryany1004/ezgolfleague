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
      comparable_scores.reject!(&:zero?)
      return 0 if comparable_scores.blank?

      comparable_scores << hole.par if @scoring_rule.include_ghost_par_scores?(users_to_compare)

      sorted_scores = comparable_scores.sort! { |x, y| x <=> y }
      best_scores = sorted_scores[0, NUMBER_OF_SCORES_TO_USE]
      summed_score = best_scores.inject(:+)

      [summed_score, 0].max # you cannot have a negative score here
    end
  end
end
