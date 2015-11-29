module GameTypes
  class TwoBestBallScorecard < GameTypes::BestBallScorecard
    
    def score_for_scores(comparable_scores, hole)            
      return 0 if comparable_scores.blank?
    
      sorted_scores = comparable_scores.sort
      
      return sorted_scores[0] + sorted_scores[1]
    end
    
  end
end