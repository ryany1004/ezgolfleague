class GameTypesController < BaseController
  before_filter :fetch_tournament
  before_filter :set_stage
  before_filter :initialize_form
  
  def index
  end

  def update
    if @tournament.update(tournament_params)
      redirect_to league_tournament_tournament_groups_path(current_user.selected_league, @tournament), :flash => { :success => "The tournament was successfully updated." }
    else
      render :edit
    end
  end
  
  private
  
  def initialize_form
    @game_types = GameTypes::GameTypeBase.available_types
  end
  
  def tournament_params
    params.require(:tournament).permit(:game_type_id)
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def set_stage
    @stage_name = "game_types"
  end
  
end
