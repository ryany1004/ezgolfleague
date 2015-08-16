class GameTypesController < BaseController
  before_filter :fetch_tournament
  before_filter :set_stage
  before_filter :initialize_form
  
  def index
  end

  def update
    if @tournament.update(tournament_params)
      @tournament.tournament_days.each do |day|
        unless params[:game_type_options][day.id.to_s].blank?          
          day.game_type.save_setup_details(params[:game_type_options][day.id.to_s])
        else          
          day.game_type.remove_game_type_options
        end
      end

      if params[:tournament_day].blank?
        @tournament_day = @tournament.first_day
      else
        @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
      end

      redirect_to league_tournament_tournament_groups_path(current_user.selected_league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The tournament was successfully updated." }
    else
      render :edit
    end
  end
  
  def options    
    game_type = self.game_type_for_id(params[:game_type_id].to_i)
    @game_type_partial_name = game_type.setup_partial
    
    unless @game_type_partial_name.blank?
      @tournament_day = @tournament.tournament_days.find(params[:day])
      @tournament_day.game_type_id = game_type.game_type_id
      
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
    params.require(:tournament).permit(tournament_days_attributes: [:id, :game_type_id])
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def set_stage
    @stage_name = "game_types"
  end
  
end
