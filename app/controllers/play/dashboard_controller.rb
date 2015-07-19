class Play::DashboardController < BaseController
  layout "golfer"
    
  def index
    @page_title = "My Dashboard"
      
    @todays_tournaments = current_user.selected_league.tournaments.where("tournament_at >= ? AND tournament_at < ?", Time.zone.now.at_beginning_of_day, Time.zone.now.at_end_of_day).order("tournament_at")
    @upcoming_tournaments = current_user.selected_league.tournaments.where("tournament_at >= ?", Time.zone.now.at_end_of_day).order("tournament_at")
    @past_tournaments = current_user.selected_league.tournaments.where("tournament_at < ?", Time.zone.now.at_beginning_of_day).order("tournament_at")

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
