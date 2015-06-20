module Play::ScorecardsHelper
  
  def cache_key_for_scorecard(scorecard_id)
    count = Scorecard.count
    max_updated_at = Scorecard.maximum(:updated_at).try(:utc).try(:to_s, :number)
    
    return "scorecards/#{scorecard_id}-#{count}-#{max_updated_at}"
  end
  
end
