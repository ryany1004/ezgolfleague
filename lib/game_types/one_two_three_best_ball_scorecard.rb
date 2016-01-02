module GameTypes
  class OneTwoThreeBestBallScorecard < GameTypes::BestBallScorecard
    
    def score_for_scores(comparable_scores, hole)                  
      return 0 if comparable_scores.blank?

      sorted_scores = comparable_scores.sort

      one_ball_selection = self.tournament_day.game_type.current_one_selection.to_i
      two_ball_selection = self.tournament_day.game_type.current_two_selection.to_i
      three_ball_selection = self.tournament_day.game_type.current_three_selection.to_i

      if one_ball_selection == hole.par
        return sorted_scores[0]
      elsif two_ball_selection == hole.par
        score_for_scores = 0
        score_for_scores += sorted_scores[0] unless sorted_scores[0].blank?
        score_for_scores += sorted_scores[1] unless sorted_scores[1].blank?
        
        return score_for_scores
      elsif three_ball_selection == hole.par        
        score_for_scores = 0
        score_for_scores += sorted_scores[0] unless sorted_scores[0].blank?
        score_for_scores += sorted_scores[1] unless sorted_scores[1].blank?
        score_for_scores += sorted_scores[2] unless sorted_scores[2].blank?
        
        return score_for_scores
      else
        score_for_scores = 0
        score_for_scores += sorted_scores[0] unless sorted_scores[0].blank?
        score_for_scores += sorted_scores[1] unless sorted_scores[1].blank?
        score_for_scores += sorted_scores[2] unless sorted_scores[2].blank?
        score_for_scores += sorted_scores[3] unless sorted_scores[3].blank?
        
        return score_for_scores
      end
    end
    
  end
end