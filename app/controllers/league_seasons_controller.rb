class LeagueSeasonsController < BaseController
  before_action :fetch_league
  before_action :fetch_season, :only => [:edit, :update, :destroy]

  def index
    @league_seasons = @league.league_seasons.order("starts_at")

    @page_title = "League Seasons"
  end

  def new
    @league_season = LeagueSeason.new
    
    @last_season = @league.league_seasons.last
    if @last_season.blank?
      @league_season.starts_at = Date.civil(Time.now.year, 1, 1)
      @league_season.ends_at = Date.civil(Time.now.year, -1, -1)
    else
      @league_season.starts_at = Date.civil(@last_season.starts_at.year, 1, 1)
      @league_season.ends_at = Date.civil(@last_season.ends_at.year, -1, -1)
    end
  end

  def create
    @league_season = LeagueSeason.new(season_params)

    if @league_season.save
      redirect_to league_league_seasons_path(@league), :flash => { :success => "The season was successfully created." }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @league_season.update(season_params)
      redirect_to league_league_seasons_path(@league), :flash => { :success => "The season was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @league_season.destroy

    redirect_to league_league_seasons_path(@league), :flash => { :success => "The season was successfully deleted." }
  end

  private

  def season_params
    params.require(:league_season).permit(:name, :starts_at, :ends_at, :league_id, :dues_amount)
  end

  def fetch_season
    @league_season = @league.league_seasons.find(params[:id])
  end

  def fetch_league
    @league = self.league_from_user_for_league_id(params[:league_id])
  end
end
