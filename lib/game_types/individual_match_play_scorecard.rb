module GameTypes
  class IndividualMatchPlayScorecard < GameTypes::DerivedScorecard
    
    def name
      return "Match Play Score"
    end
    
    def calculate_scores    
      new_scores = []
      
      user1 = self.user
      user2 = nil
      
      self.golfer_team.users.each do |u|
        if u != user
          user2 = u
        end
      end

      self.golfer_team.tournament.course.course_holes.each do |hole|
        score = DerivedScorecardScore.new
        score.strokes = self.score_for_hole(user1, user2, hole)
        score.course_hole = hole
        new_scores << score
      end
            
      self.scores = new_scores
    end
    
    def score_for_hole(user1, user2, hole)      
      return 0 if user1.blank? or user2.blank?
            
      scorecard1 = self.golfer_team.tournament.primary_scorecard_for_user(user1)
      scorecard2 = self.golfer_team.tournament.primary_scorecard_for_user(user2)
      
      strokes1 = 0
      scorecard1.scores.each do |score|
        strokes1 = score.strokes if score.course_hole == hole
      end
      
      strokes2 = 0
      scorecard2.scores.each do |score|
        strokes2 = score.strokes if score.course_hole == hole
      end
      
      if strokes1 == 0 or strokes2 == 0 #hole has not been played
        return 0
      else
        if strokes1 < strokes2
          return 1
        elsif strokes2 < strokes1
          return 0
        else
          return 0
        end
      end
    end
    
  end
end