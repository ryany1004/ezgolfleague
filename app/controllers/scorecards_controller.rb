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
    players_with_scorecards = []
    
    tournament = Tournament.find(params[:tournament_id])
    
    tournament.players.each do |player|
      unless players_with_scorecards.include? player
        players_with_scorecards << player
        
        card_hash = Hash.new
        card_hash[:primary_scorecard] = tournament.primary_scorecard_for_user(player)

        if tournament.allow_teams == GameTypes::TEAMS_ALLOWED || tournament.allow_teams == GameTypes::TEAMS_REQUIRED
          related_scorecards = tournament.related_scorecards_for_user(player)
          card_hash[:other_scorecards] = related_scorecards
          
          related_scorecards.each do |related|
            players_with_scorecards << related.golf_outing.user unless related.golf_outing.blank?
          end
        else
          card_hash[:other_scorecards] = []
        end
      
        @scorecard_groups << card_hash
      end
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
