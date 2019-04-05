module ScoringRuleScorecards
	module MatchPlayScorecardResult
		WON = 1
		LOST = 2
		TIED = 3
		INCOMPLETE = 4
	end

  class MatchPlayScorecard < ScoringRuleScorecards::BaseScorecard
  	attr_accessor :opponent
    attr_accessor :running_score
    attr_accessor :opponent_running_score
    attr_accessor :unplayed_holes
    attr_accessor :holes_won

    def name(shorten_for_print = false)
      return "Match Play"
    end

    def calculate_scores    
      new_scores = []
      
      user1 = self.user
      user2 = self.opponent

      self.unplayed_holes = self.scoring_rule.course_holes.count
      self.running_score = 0
      self.opponent_running_score = 0
      self.holes_won = 0

      user1_handicap_allowance = self.scoring_rule.handicap_computer.match_play_handicap_allowance(user: user1)
      user2_handicap_allowance = self.scoring_rule.handicap_computer.match_play_handicap_allowance(user: user2)

      self.scoring_rule.course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new
        
        running_score_holes = self.scoring_rule.course_holes.limit(i + 1)
        score.strokes = self.score_for_holes(user1, user1_handicap_allowance, user2, user2_handicap_allowance, hole, running_score_holes)
        
        score.course_hole = hole
        new_scores << score
      end
            
      self.scores = new_scores
    end
    
    def score_for_holes(user1, user1_handicap_allowance, user2, user2_handicap_allowance, current_hole, holes)      
      return 0 if user1.blank? or user2.blank?
 
      scorecard1 = self.tournament_day.primary_scorecard_for_user(user1)
      scorecard2 = self.tournament_day.primary_scorecard_for_user(user2)

      # verify the hole has been played
      current_hole_strokes1 = 0
      scorecard1.scores.each do |score|
        current_hole_strokes1 = score.strokes if score.course_hole == current_hole
      end
      
      current_hole_strokes2 = 0
      scorecard2.scores.each do |score|
        current_hole_strokes2 = score.strokes if score.course_hole == current_hole
      end
      
      return 0 if current_hole_strokes1.zero? or current_hole_strokes2.zero? # hole has not been played

      # if we get this far, we have stuff to calc
      self.unplayed_holes -= 1
      self.running_score = 0
      self.opponent_running_score = 0
      self.holes_won = 0

      holes.each do |hole|
        user1_score = scorecard1.scores.where(course_hole: hole).first
        user2_score = scorecard2.scores.where(course_hole: hole).first
        
        user1_hole_score = adjusted_strokes(user1_score.strokes, user1_handicap_allowance, hole) 
        user2_hole_score = adjusted_strokes(user2_score.strokes, user2_handicap_allowance, hole) 
                
        if user1_score.present? && user2_score.present?
          if user1_hole_score > user2_hole_score
            self.running_score = self.running_score - 1
            self.opponent_running_score = self.opponent_running_score + 1

            self.holes_won += 1
          elsif user1_hole_score < user2_hole_score
            self.running_score = self.running_score + 1
            self.opponent_running_score = self.opponent_running_score - 1
          end
        end
      end
      
      self.running_score 
    end
    
    def scorecard_result
      player_score_delta = (self.running_score - self.opponent_running_score).abs
      
      match_has_ended = false
      match_has_ended = true if player_score_delta > self.unplayed_holes or self.unplayed_holes.zero?
      return MatchPlayScorecardResult::INCOMPLETE if !match_has_ended
            
      if self.running_score == self.opponent_running_score
        MatchPlayScorecardResult::TIED
      else
        if self.running_score > self.opponent_running_score
        	MatchPlayScorecardResult::WON
        else
        	MatchPlayScorecardResult::LOST
        end
      end
    end

    def extra_scoring_column_data          
    	result = self.scorecard_result
            
      if result == MatchPlayScorecardResult::TIED
        return "All Square"
      elsif result == MatchPlayScorecardResult::LOST
      	return "L"
      elsif result == MatchPlayScorecardResult::WON
      	return "W"
      else
      	if self.unplayed_holes != self.scoring_rule.course_holes.count && self.running_score > self.opponent_running_score
      		winning_string = "#{self.running_score} and #{self.unplayed_holes}"

      		return "W (#{winning_string})"
      	end
      end

      nil
    end

  end
end