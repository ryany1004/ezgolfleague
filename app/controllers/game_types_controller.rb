class GameTypesController < BaseController
  before_filter :fetch_tournament
  
  def index
  end
  
  private
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
end
