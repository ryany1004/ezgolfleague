module ScoringRuleScorecards
  class EmptyLineScorecard < ScoringRuleScorecards::BaseScorecard
    def scores_for_course_holes(course_holes)
      course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new
        score.scorecard = self
        score.course_hole = hole

        self.scores << score
      end
    end

    def name(shorten_for_print = false)
      return "<br/><br/><br/>".html_safe
    end
  end
end
