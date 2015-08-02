class GameTypesController < BaseController
  before_filter :fetch_tournament
  before_filter :set_stage
  before_filter :initialize_form
  
  def index
  end

  def update
    if @tournament.update(tournament_params)
      unless params[:game_type_options].blank? 
        @tournament.game_type.save_setup_details(params[:game_type_options])
      else
        @tournament.game_type.remove_game_type_options
      end
      
      redirect_to league_tournament_tournament_groups_path(current_user.selected_league, @tournament), :flash => { :success => "The tournament was successfully updated." }
    else
      render :edit
    end
  end
  
  def options    
    game_type = self.game_type_for_id(params[:game_type_id].to_i)
    @game_type_partial_name = game_type.setup_partial
    
    unless @game_type_partial_name.blank?
      @tournament.game_type_id = game_type.game_type_id
      
      respond_to do |format|
        format.js {}
      end
    else
      render :text => "There are no configurable options for this game type.", :layout => false
    end
  end
  
  def game_type_for_id(game_type_id)
    @game_types.each do |type|
      return type if type.game_type_id == game_type_id
    end
    
    return nil
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
