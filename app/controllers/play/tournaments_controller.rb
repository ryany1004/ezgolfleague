class Play::TournamentsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_tournament
  
  def signup
  end
  
  def complete_signup
    tournament_group = TournamentGroup.find(params[:group_id])
    
    if @tournament.includes_player?(current_user)
      redirect_to play_tournament_signup_path(@tournament), :flash => { :error => "You are already registered for this tournament. Remove your existing registration and try again." }
    else
      @tournament.add_player_to_group(tournament_group, current_user)
      
      redirect_to play_tournament_signup_path(@tournament), :flash => { :success => "You are registered for the tournament." }
    end
  end
  
  def remove_signup
    tournament_group = TournamentGroup.find(params[:group_id])

    @tournament.remove_player_from_group(tournament_group, current_user)

    redirect_to play_tournament_signup_path(@tournament), :flash => { :success => "Your registration has been canceled." }
  end
  
  private
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
end
