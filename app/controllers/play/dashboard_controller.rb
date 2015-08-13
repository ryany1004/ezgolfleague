class Play::DashboardController < BaseController
  layout "golfer"
    
  def index
    @page_title = "My Dashboard"
    
    @todays_tournaments = Tournament.all_today([current_user.selected_league])
    @upcoming_tournaments = Tournament.all_upcoming([current_user.selected_league])
    @past_tournaments = Tournament.all_past([current_user.selected_league])

    @rankings = current_user.selected_league.ranked_users_for_year(Date.today.year.to_s)
  
    @has_unpaid_upcoming_tournaments = false
    @todays_tournaments.each do |t|
      @has_unpaid_upcoming_tournaments = false if !t.user_has_paid?(current_user)
    end
  end
  
  def switch_leagues
    league = League.find(params[:league_id])
    current_user.current_league = league
    current_user.save
    
    redirect_to play_dashboard_index_path
  end
  
end
