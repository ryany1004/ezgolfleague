class Play::DashboardController < ApplicationController
  layout "golfer"
  
  before_action :authenticate_user!
  
  def index
    @page_title = "My Dashboard"
      
    @todays_tournament = current_user.selected_league.tournaments.where("tournament_at >= ? AND tournament_at < ?", Date.today, Date.tomorrow).first
    
    @upcoming_tournaments = current_user.selected_league.tournaments.where("tournament_at >= ?", Date.tomorrow)
    @past_tournaments = current_user.selected_league.tournaments.where("tournament_at < ?", Date.today)
    
    #ranking information
  end
  
  def switch_leagues
    league = League.find(params[:league_id])
    current_user.current_league = league
    current_user.save
    
    redirect_to play_dashboard_index_path
  end
  
end
