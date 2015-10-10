class LeagueSeasonsController < BaseController
  before_action :fetch_season, :only => [:edit, :update, :destroy]
  before_action :fetch_league
  
  def index 
    @league_seasons = @league.league_seasons.order("starts_at DESC")
    
    @page_title = "League Seasons"
  end
  
  def new
    @league_season = LeagueSeason.new
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
    params.require(:league_season).permit(:name, :starts_at, :ends_at, :league_id)
  end
  
  def fetch_season
    @league_season = LeagueSeason.find(params[:id])
  end
  
  def fetch_league
    @league = League.find(params[:league_id])
  end
end
