class Api::V1::TournamentDaysController < Api::V1::ApiBaseController
  before_filter :protect_with_token
  before_filter :fetch_details
  
  respond_to :json
  
  def tournament_groups
    eager_groups = TournamentGroup.includes(golf_outings: [{scorecard: :scores}, :user]).where(tournament_day: @tournament_day)
    
    respond_with(eager_groups) do |format|
      format.json { render :json => eager_groups }
    end
  end
   
  def leaderboard 
    leaderboard = Rails.cache.fetch(@tournament_day.leaderboard_api_cache_key, expires_in: 8.minutes, race_condition_ttl: 10)
    if leaderboard.blank?
      logger.info { "Fetching Leaderboard - Not Cached" }
      
      leaderboard = self.fetch_leaderboard
      
      Rails.cache.write(@tournament_day.leaderboard_api_cache_key, leaderboard)
    else
      logger.info { "Returning Cached Leaderboard" }
    end
        
    respond_with(leaderboard) do |format|
      format.json { render :json => leaderboard }
    end
  end
  
  def fetch_details
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end
  
  def fetch_leaderboard
    day_flights_with_rankings = @tournament_day.flights_with_rankings
    combined_flights_with_rankings = FetchingTools::LeaderboardFetching.flights_with_rankings_could_be_combined(@tournament_day, day_flights_with_rankings)
    
    leaderboard = {:day_flights => day_flights_with_rankings, :combined_flights => combined_flights_with_rankings}
  end
  
end