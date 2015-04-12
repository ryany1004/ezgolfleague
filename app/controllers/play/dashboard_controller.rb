class Play::DashboardController < ApplicationController
  layout "golfer"
  
  def index
    @page_title = "My Dashboard"
    
    @upcoming_tournaments = current_user.selected_league.tournaments.where("tournament_at >= ?", Time.now)
    @past_tournaments = current_user.selected_league.tournaments.where("tournament_at < ?", Time.now)
    
    #ranking information
  end
  
  def switch_leagues
    league = League.find(params[:league_id])
    current_user.current_league = league
    current_user.save
    
    redirect_to play_dashboard_index_path
  end
  
end
