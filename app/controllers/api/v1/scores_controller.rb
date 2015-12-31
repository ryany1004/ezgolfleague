class Api::V1::ScoresController < Api::V1::ApiBaseController
  
  def batch_update
    scores = ActiveSupport::JSON.decode(request.body.read)
        
    first_score_dict = scores[0]
    score_id = first_score_dict["scoreServerID"]
    score = Score.where(id: score_id).first
    
    unless score.blank?
      self.fetch_scorecards_for_id(score.scorecard.id)
      
      scores.each do |update_score|        
        scores_to_update = {update_score["scoreServerID"] => {:strokes => update_score["score"]}}
                
        logger.debug { "Sending: #{scores_to_update}" }
        
        UpdatingTools::ScorecardUpdating.update_scorecards_for_scores(scores_to_update, @scorecard, @other_scorecards)
      end
      
      render json: {:text => "Success"}
    else
      render text: "Score Updating Failure", :status => :bad_request
    end
  end
  
  def fetch_scorecards_for_id(scorecard_id)
    scorecard_info = FetchingTools::ScorecardFetching.fetch_scorecards_and_related(scorecard_id)
    
    @scorecard = scorecard_info[:scorecard]
    @tournament_day = scorecard_info[:tournament_day]
    @tournament = scorecard_info[:tournament]
    @other_scorecards = scorecard_info[:other_scorecards]
  end
  
end