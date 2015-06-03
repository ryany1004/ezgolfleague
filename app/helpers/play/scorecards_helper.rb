module Play::ScorecardsHelper
  
  def cache_key_for_scorecard_forms
    count = Scorecard.count
    max_updated_at = Scorecard.maximum(:updated_at).try(:utc).try(:to_s, :number)
    
    return "scorecards/all-#{count}-#{max_updated_at}"
  end
  
end
