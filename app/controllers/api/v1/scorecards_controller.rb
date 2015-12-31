class Api::V1::ScorecardsController < Api::V1::ApiBaseController
  before_action :fetch_scorecards

  def update
    
  end
  
  def fetch_scorecards
    scorecard_info = FetchingTools::ScorecardFetching.fetch_scorecards_and_related(params[:id])
    
    @scorecard = scorecard_info[:scorecard]
    @tournament_day = scorecard_info[:tournament_day]
    @tournament = scorecard_info[:tournament]
    @other_scorecards = scorecard_info[:other_scorecards]
  end
  
end