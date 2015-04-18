class ScorecardsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_all_params, :only => [:update, :edit]
  
  def index
    @tournament = Tournament.find(params[:tournament_id])
    @players = @tournament.players
    
    @page_title = "Scorecards"
  end
  
  def edit
  end
  
  def update
    if @scorecard.update(scorecard_params)
      redirect_to scorecards_path(tournament_id: @tournament), :flash => { :success => "The scorecard was successfully updated." }
    else      
      render :edit
    end
  end
 
  private
  
  def scorecard_params
    params.require(:scorecard).permit(scores_attributes: [:id, :strokes])
  end
  
  def fetch_all_params
    @scorecard = Scorecard.find(params[:id])
    @player = @scorecard.golf_outing.user
    @tournament = @scorecard.golf_outing.team.tournament_group.tournament
  end
  
end
