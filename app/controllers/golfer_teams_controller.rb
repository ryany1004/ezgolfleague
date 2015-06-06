class GolferTeamsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_golfer_teams, :only => [:index, :populate]
  before_filter :fetch_golfer_team, :only => [:edit, :update, :destroy]
  before_filter :set_stage
  
  def index
    @page_title = "Teams"
  end
  
  def new
    @golfer_team = GolferTeam.new
  end
  
  def create
    @golfer_team = GolferTeam.new(golfer_team_params)
    @golfer_team.tournament = @tournament
    @golfer_team.are_opponents = @tournament.game_type.team_players_are_opponents?
    
    if @golfer_team.save
      if params[:commit] == "Save & Continue"
        redirect_to league_tournament_flights_path(@tournament.league, @tournament), :flash => { :success => "The team was successfully created." }
      else
        redirect_to league_tournament_golfer_teams_path(@tournament.league, @tournament), :flash => { :success => "The team was successfully created." }
      end 
    else      
      render :new
    end
  end
  
  def edit
    @golfer_team.requested_tournament_group_id = @tournament.tournament_group_for_player(@golfer_team.users.first).id unless @golfer_team.users.blank?
  end
  
  def update
    if @golfer_team.update(golfer_team_params)
      if !@golfer_team.requested_tournament_group_id.blank? #handle tee times        
        @golfer_team.rebalance_tournament_groups_for_request
      end
          
      if params[:commit] == "Save & Continue"
        redirect_to league_tournament_tournament_groups_path(@tournament.league, @tournament), :flash => { :success => "The team was successfully updated." }
      else
        redirect_to league_tournament_golfer_teams_path(@tournament.league, @tournament), :flash => { :success => "The team was successfully updated." }
      end 
    else
      render :edit
    end
  end
  
  def destroy
    @golfer_team.destroy
    
    redirect_to league_tournament_golfer_teams_path(@tournament.league, @tournament), :flash => { :success => "The team was successfully deleted." }
  end
  
  private
  
  def set_stage
    @stage_name = "teams"
  end
  
  def fetch_golfer_teams
    @golfer_teams = @tournament.golfer_teams
  end
  
  def fetch_golfer_team
    @golfer_team = @tournament.golfer_teams.find(params[:id])
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def golfer_team_params
    params.require(:golfer_team).permit(:tournament_id, :max_players, :requested_tournament_group_id, :user_ids => [])
  end

end
