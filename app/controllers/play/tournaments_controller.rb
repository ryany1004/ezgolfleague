class Play::TournamentsController < BaseController
  layout "golfer"
  
  before_action :fetch_tournament, :except => [:show]
  
  def show
    @tournament = Tournament.find(params[:id])
  
    @page_title = "#{@tournament.name}"
  end
  
  def signup
  end
  
  def complete_signup
    tournament_group = TournamentGroup.find(params[:group_id])
    
    if @tournament.includes_player?(current_user)
      redirect_to play_tournament_signup_path(@tournament), :flash => { :error => "You are already registered for this tournament. Remove your existing registration and try again." }
    else
      @tournament.add_player_to_group(tournament_group, current_user)
      
      redirect_to play_dashboard_index_path, :flash => { :success => "You are registered for the tournament." }
    end
  end
  
  def remove_signup
    @tournament.tournament_groups.each do |tg|
      tg.teams.each do |team|
        team.golf_outings.each do |outing|
          @tournament.remove_player_from_group(tg, current_user) if outing.user == current_user
        end
      end
    end
    
    redirect_to play_dashboard_index_path, :flash => { :success => "Your registration has been canceled." }
  end
  
  private
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
end
