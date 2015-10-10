class Play::DashboardController < BaseController
  layout "golfer"
    
  def index
    @page_title = "My Dashboard"
    
    active_season = current_user.selected_league.league_seasons.where("starts_at < ? AND ends_at > ?", Date.today, Date.today).first
    if session[:selected_season_id].blank?      
      @league_season = active_season
    else
      @league_season = current_user.selected_league.league_seasons.find(session[:selected_season_id])
    end
    
    @has_unpaid_upcoming_tournaments = false
    
    if @league_season == active_season
      @todays_tournaments = Tournament.all_today([current_user.selected_league])

      @todays_tournaments.each do |t|
        @has_unpaid_upcoming_tournaments = false if !t.user_has_paid?(current_user)
      end
    end

    @upcoming_tournaments = Tournament.all_upcoming([current_user.selected_league], @league_season.ends_at)
    @past_tournaments = Tournament.all_past([current_user.selected_league], @league_season.starts_at)

    @rankings = current_user.selected_league.ranked_users_for_year(@league_season.starts_at, @league_season.ends_at)
  end
  
  def switch_seasons
    session[:selected_season_id] = params[:season_id]
    
    redirect_to play_dashboard_index_path
  end
  
  def switch_leagues
    league = League.find(params[:league_id])
    current_user.current_league = league
    current_user.save
    
    redirect_to play_dashboard_index_path
  end
  
end
