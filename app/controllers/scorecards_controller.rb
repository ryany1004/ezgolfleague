class ScorecardsController < BaseController
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
 
  def print
    @scorecard_groups = []
    
    tournament = Tournament.find(params[:tournament_id])
    
    tournament.players.each do |player|
      card_hash = Hash.new
      card_hash[:primary_scorecard] = tournament.primary_scorecard_for_user(player)
      
      if tournament.allow_teams == GameTypes::TEAMS_ALLOWED || tournament.allow_teams == GameTypes::TEAMS_REQUIRED
        card_hash[:other_scorecards] = tournament.related_scorecards_for_user(player)
      else
        card_hash[:other_scorecards] = []
      end
      
      @scorecard_groups << card_hash
    end
    
    render layout: false
  end
 
  private
  
  def scorecard_params
    params.require(:scorecard).permit(scores_attributes: [:id, :strokes])
  end
  
  def fetch_all_params
    @scorecard = Scorecard.find(params[:id])
    @player = @scorecard.golf_outing.user
    @tournament = @scorecard.golf_outing.team.tournament_group.tournament
    @handicap_allowance = @tournament.handicap_allowance(@scorecard.golf_outing.user)
  end
  
end
