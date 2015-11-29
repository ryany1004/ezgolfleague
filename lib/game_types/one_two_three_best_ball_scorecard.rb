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
        return sorted_scores[0] + sorted_scores[1]
      elsif three_ball_selection == hole.par
        return sorted_scores[0] + sorted_scores[1] + sorted_scores[2]
      else
        return sorted_scores[0] + sorted_scores[1] + sorted_scores[2] + sorted_scores[3]
      end
    end
    
  end
end