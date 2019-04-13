module ScoringRuleScorecards
	class TeamMatchPlayBestBallScorecard < ScoringRuleScorecards::MatchPlayScorecard
  	attr_accessor :team_a_scorecard
  	attr_accessor :team_b_scorecard
    attr_accessor :team_a_running_score
    attr_accessor :team_b_running_score
    attr_accessor :unplayed_holes
    attr_accessor :team_a_holes_won
    attr_accessor :team_b_holes_won

    def calculate_scores    
      new_scores = []
      
      self.unplayed_holes = self.scoring_rule.course_holes.count
      self.running_score = 0
      self.opponent_running_score = 0
      self.holes_won = 0

      self.scoring_rule.course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new
        
        running_score_holes = self.scoring_rule.course_holes.limit(i + 1)
        score.strokes = self.score_for_holes(self.team_a_scorecard, self.team_b_scorecard, hole, running_score_holes)
        
        score.course_hole = hole
        new_scores << score
      end
            
      self.scores = new_scores
    end
    
    def score_for_holes(team_a_scorecard, team_b_scorecard, current_hole, holes)      
      return 0 if team_a_scorecard.blank? || team_a_scorecard.blank?

      # verify the hole has been played
      current_hole_strokes1 = 0
      team_a_scorecard.scores.each do |score|
        current_hole_strokes1 = score.strokes if score.course_hole == current_hole
      end
      
      current_hole_strokes2 = 0
      team_b_scorecard.scores.each do |score|
        current_hole_strokes2 = score.strokes if score.course_hole == current_hole
      end
      
      return 0 if current_hole_strokes1.zero? || current_hole_strokes2.zero? # hole has not been played

      # if we get this far, we have stuff to calc
      self.unplayed_holes -= 1
      self.running_score = 0
      self.opponent_running_score = 0
      self.team_a_holes_won = 0
      self.team_b_holes_won = 0

      holes.each_with_index do |hole, i|
        user1_score = team_a_scorecard.scores[i]
        user2_score = team_b_scorecard.scores[i]
   
        if user1_score.present? && user2_score.present?
          if user1_score.strokes > user2_score.strokes
            self.running_score = (self.running_score - 1).abs
            self.opponent_running_score = (self.opponent_running_score + 1).abs

            self.team_a_holes_won += 1
          elsif user1_score.strokes < user2_score.strokes
            self.running_score = (self.running_score + 1).abs
            self.opponent_running_score = (self.opponent_running_score - 1).abs

            self.team_b_holes_won += 1
          end
        end
      end
      
      self.running_score 
    end

    def winning_team
    	if self.team_a_holes_won > self.team_b_holes_won
    		self.team_a_scorecard.team
    	elsif self.team_b_holes_won > self.team_a_holes_won
    		self.team_b_scorecard.team
    	else
    		return nil
    	end
    end

	end
end