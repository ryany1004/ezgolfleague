class LeagueSeasonTeamsController < BaseController
  before_action :fetch_season
  before_action :fetch_league_season_team, only: [:edit, :update, :destroy, :update_player, :delete_player]
  before_action :fetch_available_users, only: [:edit]

  def index
    @league_season_teams = @league_season.league_season_teams.order(:name)

    @page_title = "Season Teams"
  end

  def new
    @league_season_team = LeagueSeasonTeam.new
  end

  def create
    @league_season_team = LeagueSeasonTeam.new(team_params)
    @league_season_team.league_season = @league_season

    if @league_season_team.save
      redirect_to league_league_season_league_season_teams_path(@league, @league_season), flash: { success: "The team was successfully created." }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @league_season_team.update(scoring_group_params)
      redirect_to league_league_season_league_season_teams_path(@league, @league_season), flash: { success: "The team was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @league_season_team.destroy

    redirect_to league_league_season_league_season_teams_path(@league, @league_season), flash: { success: "The team was successfully deleted." }
  end

  def update_player
    @user = @league.users.find(params[:add_player][:user_id])
    @league_season_team.users << @user

    @league_season_team.update_team_name

    redirect_to edit_league_league_season_league_season_team_path(@league, @league_season, @league_season_team)
  end

  def delete_player
    @user = @league.users.find(params[:user])
    @league_season_team.users.destroy(@user)

    @league_season_team.update_team_name

    redirect_to edit_league_league_season_league_season_team_path(@league, @league_season, @league_season_team)
  end

  private

  def team_params
    params.require(:league_season_team).permit(:name)
  end

  def fetch_league_season_team
    if params[:league_season_team_id].blank?
      id = params[:id]
    else
      id = params[:league_season_team_id]
    end
        
  	@league_season_team = @league_season.league_season_teams.find(id)
  end

  def fetch_available_users
    @players = @league_season.users_not_in_teams
  end

  def fetch_season
  	fetch_league

    @league_season = @league.league_seasons.find(params[:league_season_id])
  end

  def fetch_league
    @league = self.league_from_user_for_league_id(params[:league_id])
  end
end