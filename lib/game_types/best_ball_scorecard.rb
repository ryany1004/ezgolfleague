module GameTypes
  class BestBallScorecard < GameTypes::DerivedScorecard
    
    def name
      return "Best Ball"
    end
    
    def should_subtotal?
      return true
    end
  
    def should_total?
      return true
    end
    
    def calculate_scores    
      new_scores = []

      self.golfer_team.tournament.course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new
        
        comparable_scores = []
        self.golfer_team.users.each do |user|
          scorecard = self.golfer_team.tournament.primary_scorecard_for_user(user)
          hole_score = scorecard.scores.where(course_hole: hole).first
          
          comparable_scores << hole_score
        end
        
        score.strokes = self.lowest_score_for_scores(comparable_scores)
        
        score.course_hole = hole
        new_scores << score
      end
            
      self.scores = new_scores
    end
    
    def lowest_score_for_scores(comparable_scores)      
      return 0 if comparable_scores.blank?
      
      lowest_score = comparable_scores.first.strokes
            
      comparable_scores.each do |score|
        if score.strokes == 0 #not yet played
          return lowest_score
        else
          lowest_score = score.strokes if score.strokes < lowest_score
        end
      end

      return lowest_score
    end
    
  end
end