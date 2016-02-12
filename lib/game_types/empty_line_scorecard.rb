module GameTypes
  class EmptyLineScorecard < GameTypes::DerivedScorecard

    def scores_for_course_holes(course_holes)
      course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new
        score.scorecard = self
        score.course_hole = hole
        
        self.scores << score
      end
    end
    
    def name(shorten_for_print = false)
      return ""
    end
    
  end
end