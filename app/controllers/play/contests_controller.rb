class Play::ContestsController < BaseController
  layout "golfer"
  
  before_action :fetch
  
  def index
  end
  
  def fetch
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @contests = @tournament_day.contests
  end
  
end
