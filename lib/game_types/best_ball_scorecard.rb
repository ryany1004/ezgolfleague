module GameTypes
  class BestBallScorecard < GameTypes::DerivedScorecard
    attr_accessor :should_use_handicap
    attr_accessor :handicap_indices
    attr_accessor :course_hole_number_suppression_list
    
    def initialize
      super
      
      self.handicap_indices = Hash.new
      self.course_hole_number_suppression_list = []
    end
    
    def name
      if self.should_use_handicap == true
        return "Best Ball Net"
      else
        return "Best Ball Gross"
      end
    end
    
    def should_subtotal?
      return true
    end
  
    def should_total?
      return true
    end
    
    def handicap_allowance_for_user(user)
      if self.should_use_handicap == false
        return nil
      end
      
      if self.handicap_indices["#{user.id}"]
        return self.handicap_indices["#{user.id}"]
      else
        handicap_allowance = self.tournament_day.handicap_allowance(user)
        self.handicap_indices["#{user.id}"] = handicap_allowance
        
        return handicap_allowance
      end
    end
    
    def calculate_scores    
      new_scores = []

      if golfer_team.blank?
        Rails.logger.debug { "Calculate Scores - No Team" }
        
        return
      end

      self.golfer_team.tournament_day.course_holes.each_with_index do |hole, i|
        if self.course_hole_number_suppression_list.include? hole.hole_number
          score = DerivedScorecardScore.new
          score.strokes = 0
          score.scorecard = self
          score.course_hole = hole
          
          new_scores << score
        else
          score = DerivedScorecardScore.new
          score.scorecard = self
        
          comparable_scores = []
          self.golfer_team.users.each do |user|
            scorecard = self.golfer_team.tournament_day.primary_scorecard_for_user(user)
                
            raw_score = scorecard.scores.where(course_hole: hole).first.strokes
            if self.should_use_handicap == true
              if raw_score == 0
                hole_score = 0
              else
                hole_score = self.adjusted_strokes(raw_score, self.handicap_allowance_for_user(user), hole)
              end
            else
              hole_score = raw_score
            end

            comparable_scores << hole_score
          end
        
          score.strokes = self.score_for_scores(comparable_scores, hole)
        
          score.course_hole = hole
          new_scores << score
        end
      end
            
      self.scores = new_scores
    end
    
    def score_for_scores(comparable_scores, hole)      
      return 0 if comparable_scores.blank?

      sorted_scores = comparable_scores.sort
            
      return sorted_scores[0]
    end
    
  end
end