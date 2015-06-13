module GameTypes
  class IndividualMatchPlayScorecard < GameTypes::DerivedScorecard
    
    def name
      return "Match Play"
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

      self.golfer_team.tournament.course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new
        
        running_score_holes = self.golfer_team.tournament.course_holes.limit(i + 1)
        score.strokes = self.score_for_holes(user1, user2, hole, running_score_holes)
        
        score.course_hole = hole
        new_scores << score
      end
            
      self.scores = new_scores
    end
    
    def score_for_holes(user1, user2, current_hole, holes)      
      return 0 if user1.blank? or user2.blank?
            
      scorecard1 = self.golfer_team.tournament.primary_scorecard_for_user(user1)
      scorecard2 = self.golfer_team.tournament.primary_scorecard_for_user(user2)

      #verify the hole has been played
      current_hole_strokes1 = 0
      scorecard1.scores.each do |score|
        current_hole_strokes1 = score.strokes if score.course_hole == current_hole
      end
      
      current_hole_strokes2 = 0
      scorecard2.scores.each do |score|
        current_hole_strokes2 = score.strokes if score.course_hole == current_hole
      end
      
      return 0 if current_hole_strokes1 == 0 or current_hole_strokes2 == 0 #hole has not been played

      #if we get this far, we have stuff to calc
      
      user1_running_score = 0
      
      holes.each do |hole|
        user1_score = scorecard1.scores.where(course_hole: hole).first
        user2_score = scorecard2.scores.where(course_hole: hole).first
        
        unless user1_score.blank? || user2_score.blank?
          if user1_score.strokes > user2_score.strokes
            user1_running_score = user1_running_score - 1
          elsif user1_score.strokes < user2_score.strokes
            user1_running_score = user1_running_score + 1
          end
        end
      end
      
      return user1_running_score 
    end
    
  end
end