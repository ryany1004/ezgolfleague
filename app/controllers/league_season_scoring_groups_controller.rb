class LeagueSeasonScoringGroupsController < BaseController
  before_action :fetch_season
  before_action :fetch_scoring_group, only: [:edit, :update, :destroy, :update_player, :delete_player]
  before_action :fetch_available_users, only: [:edit]

  def index
    @scoring_groups = @league_season.league_season_scoring_groups.order("name")

    @page_title = "Season Scoring Groups"
  end

  def new
    @scoring_group = LeagueSeasonScoringGroup.new
  end

  def create
    @scoring_group = LeagueSeasonScoringGroup.new(scoring_group_params)
    @scoring_group.league_season = @league_season

    if @scoring_group.save
      redirect_to league_league_season_league_season_scoring_groups_path(@league, @league_season), flash: { success: "The scoring group was successfully created." }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @scoring_group.update(scoring_group_params)
      redirect_to league_league_season_league_season_scoring_groups_path(@league, @league_season), flash: { success: "The scoring group was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @scoring_group.destroy

    redirect_to league_league_season_league_season_scoring_groups_path(@league, @league_season), flash: { success: "The scoring group was successfully deleted." }
  end

  def update_player
    @user = @league.users.find(params[:add_player][:user_id])

    @scoring_group.users << @user

    redirect_to edit_league_league_season_league_season_scoring_group_path(@league, @league_season, @scoring_group)
  end

  def delete_player
    @user = @league.users.find(params[:user])

    @scoring_group.users.destroy(@user)

    redirect_to edit_league_league_season_league_season_scoring_group_path(@league, @league_season, @scoring_group)
  end

  private

  def scoring_group_params
    params.require(:league_season_scoring_group).permit(:name)
  end

  def fetch_scoring_group
    if params[:league_season_scoring_group_id].blank?
      id = params[:id]
    else
      id = params[:league_season_scoring_group_id]
    end
        
  	@scoring_group = @league_season.league_season_scoring_groups.find(id)
  end

  def fetch_available_users
    @players = @league_season.users_not_in_scoring_groups
  end

  def fetch_season
  	fetch_league

    @league_season = @league.league_seasons.find(params[:league_season_id])
  end

  def fetch_league
    @league = self.league_from_user_for_league_id(params[:league_id])
  end
end