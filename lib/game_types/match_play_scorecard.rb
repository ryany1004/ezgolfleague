module GameTypes
  class MatchPlayScorecard < GameTypes::DerivedScorecard
    
    def calculate_scores    
      new_scores = []
        
      self.golfer_team.tournament.course.course_holes.each do |hole|
        score = TeamScorecardScore.new
        score.strokes = 0
        score.course_hole = hole
        new_scores << score
      end
      
      self.scores = new_scores
    end
    
    def score_for_hole(hole)
      
    end
    
  end
end