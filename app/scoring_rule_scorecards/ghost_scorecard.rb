module ScoringRuleScorecards
  class GhostScorecard < ScoringRuleScorecards::BaseScorecard
    def calculate_scores
      scoring_rule.tournament_day.scorecard_base_scoring_rule.course_holes.each do |hole|
        score = DerivedScorecardScore.new
        score.scorecard = self
        score.course_hole = hole
        score.strokes = hole.par
        score.net_strokes = hole.par

        scores << score
      end
    end

    def name(_ = false)
      'Ghost'
    end
  end
end
