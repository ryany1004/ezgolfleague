module Play::ScorecardsHelper
  
  def cache_key_for_scorecard(scorecard_id)
    count = Scorecard.count
    max_updated_at = Scorecard.maximum(:updated_at).try(:utc).try(:to_s, :number)
    
    return "scorecards/#{scorecard_id}-#{count}-#{max_updated_at}"
  end

  def front_nine_handicap_for_scorecard(scorecard)
    handicap_score = scorecard.front_nine_score(true)
    non_handicap_score = scorecard.front_nine_score(false)
    
    if scorecard.can_display_handicap? && handicap_score != non_handicap_score
      return "<span class='label label-success'>#{handicap_score}</span>"
    else
      return nil
    end
  end
  
  def back_nine_handicap_for_scorecard(scorecard)
    handicap_score = scorecard.back_nine_score(true)
    non_handicap_score = scorecard.back_nine_score(false)
    
    if scorecard.can_display_handicap? && handicap_score != non_handicap_score
      return "<span class='label label-success'>#{handicap_score}</span>"
    else
      return nil
    end
  end
  
end
