class Play::TournamentsController < BaseController
  layout "golfer"
  
  before_action :fetch_tournament, :except => [:show]
  
  def show
    @tournament = Tournament.find(params[:id])
    
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    @flights_with_rankings = self.fetch_flights_with_rankings(@tournament_day)
    @flights_with_rankings = self.fetch_combined_flights_with_rankings(@tournament_day, @flights_with_rankings)

    @page_title = "#{@tournament.name}"
  end
  
  def leaderboard
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:day])
    @user_scorecard = @tournament_day.primary_scorecard_for_user(current_user)
    
    @day_flights_with_rankings = self.fetch_flights_with_rankings(@tournament_day)
    @combined_flights_with_rankings = self.fetch_combined_flights_with_rankings(@tournament_day, @day_flights_with_rankings)
    
    @page_title = "#{@tournament.name} Leaderboard"
  end
  
  ##
  
  def confirm
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.first_day
    
    outing = @tournament_day.golf_outing_for_player(current_user)
    outing.is_confirmed = true
    outing.save
    
    redirect_to play_dashboard_index_path, :flash => { :success => "You are confirmed for the tournament." } 
  end
  
  ##
  
  def signup
    if @tournament.show_players_tee_times == true
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
      paying_now = false
      paying_now = true if !params[:pay_now].blank?
      
      @tournament.first_day.add_player_to_group(tournament_group, current_user, paying_now)
      
      #other associated signup
      if !params[:tournament].blank? && !params[:tournament][:another_member_id].blank?
        other_user = User.find(params[:tournament][:another_member_id])
        
        @tournament.first_day.add_player_to_group(tournament_group, other_user, false, false)
      end
      
      #contests
      if !params[:tournament].blank? && !params[:tournament][:contests_to_enter].blank?
        params[:tournament][:contests_to_enter].each do |contest_id|
          unless contest_id.blank?
            contest = Contest.find(contest_id)
            
            contest.add_user(current_user)
          end
        end
      end
      
      #payment
      if paying_now == true       
        redirect_to new_play_payment_path(:payment_type => "tournament_dues", :tournament_id => @tournament.id)
      else        
        redirect_to play_dashboard_index_path, :flash => { :success => "You are registered for the tournament." }
      end
    end
  end
  
  def remove_signup
    @tournament.tournament_days.each do |day|
      day.tournament_groups.each do |tg|
        tg.teams.each do |team|
          team.golf_outings.each do |outing|
            day.remove_player_from_group(tg, current_user) if outing.user == current_user
          end
        end
      end
    end

    redirect_to play_dashboard_index_path, :flash => { :success => "Your registration has been canceled." }
  end
  
  def fetch_flights_with_rankings(tournament_day)  
    return tournament_day.flights_with_rankings
  end
  
  def fetch_combined_flights_with_rankings(tournament_day, day_flights_with_rankings)
    return FetchingTools::LeaderboardFetching.flights_with_rankings_could_be_combined(tournament_day, day_flights_with_rankings)
  end
  
  private
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
end
