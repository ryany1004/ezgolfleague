class GameTypesController < BaseController
  before_filter :fetch_tournament
  before_action :set_stage
  
  def index
  end
  
  private
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def set_stage
    @stage_name = "game_types"
  end
  
end
