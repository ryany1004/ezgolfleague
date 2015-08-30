class ScorecardsController < BaseController
  before_action :fetch_all_params, :only => [:update, :edit]
  
  def index
    @tournament = Tournament.find(params[:tournament_id])
    @players = @tournament.players
    
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    @page_title = "Scorecards"
  end
  
  def edit
  end
  
  def update
    if @scorecard.update(scorecard_params)
      @scorecard.tournament_day.score_user(@scorecard.golf_outing.user)
      
      redirect_to scorecards_path(tournament_id: @tournament), :flash => { :success => "The scorecard was successfully updated." }
    else      
      render :edit
    end
  end
 
  def print
    @scorecard_groups = []
    players_with_scorecards = []
    
    tournament = Tournament.find(params[:tournament_id])
    
    if params[:tournament_day].blank?
      tournament_day = tournament.first_day
    else
      tournament_day = tournament.tournament_days.find(params[:tournament_day])
    end
    
    tournament.players.each do |player|
      unless players_with_scorecards.include? player
        players_with_scorecards << player
      
        unless tournament_day.primary_scorecard_for_user(player).blank?
          card_hash = Hash.new
          card_hash[:primary_scorecard] = tournament_day.primary_scorecard_for_user(player)

          if tournament_day.allow_teams == GameTypes::TEAMS_ALLOWED || tournament_day.allow_teams == GameTypes::TEAMS_REQUIRED
            related_scorecards = tournament_day.related_scorecards_for_user(player)
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
    @tournament_day = @scorecard.golf_outing.team.tournament_group.tournament_day
    @tournament = @tournament_day.tournament
    @handicap_allowance = @tournament_day.handicap_allowance(@scorecard.golf_outing.user)
  end
  
end
