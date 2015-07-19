class Play::TournamentsController < BaseController
  layout "golfer"
  
  before_action :fetch_tournament, :except => [:show]
  
  def show
    @tournament = Tournament.find(params[:id])

    @page_title = "#{@tournament.name}"
  end
  
  def signup
    if @tournament.game_type.show_players_tee_times == true
      render "signup_with_times"
    else
      render "signup_without_times"
    end
  end
  
  def complete_signup
    tournament_group = TournamentGroup.find(params[:group_id])
    
    if @tournament.includes_player?(current_user)
      redirect_to play_tournament_signup_path(@tournament), :flash => { :error => "You are already registered for this tournament. Remove your existing registration and try again." }
    else
      #primary user
      if !params[:pay_now].blank?        
        pay_now = true
        
        #TODO REDO
        #payment = TournamentPayment.create(user: current_user, tournament: @tournament, payment_amount: @tournament.dues_amount) if !@tournament.user_has_paid?(current_user)
      else        
        pay_now = false
      end

      @tournament.add_player_to_group(tournament_group, current_user)
      
      #other associated signup
      if !params[:tournament].blank? && !params[:tournament][:another_member_id].blank?
        other_user = User.find(params[:tournament][:another_member_id])
        @tournament.add_player_to_group(tournament_group, other_user, false)
      end
      
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
