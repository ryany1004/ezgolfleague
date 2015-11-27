class TournamentsController < BaseController
  before_filter :fetch_tournament, :only => [:edit, :update, :destroy, :signups, :manage_holes, :update_holes, :add_signup, :delete_signup, :finalize, :confirm_finalization, :update_course_handicaps, :touch_tournament, :update_auto_schedule, :auto_schedule, :confirmed_players]
  before_filter :initialize_form, :only => [:new, :edit]
  before_filter :set_stage
  
  def index
    if current_user.is_super_user?
      @upcoming_tournaments = Tournament.all_upcoming(nil).page params[:page]
      @past_tournaments = Tournament.all_past(nil).page params[:page]
    else
      @upcoming_tournaments = Tournament.all_upcoming(current_user.leagues).page params[:page]
      @past_tournaments = Tournament.all_past(current_user.leagues).page params[:page]
    end

    @page_title = "Tournaments"
  end
  
  def new
    @tournament = Tournament.new
    @tournament.league = current_user.leagues.first if current_user.leagues.count == 1
    @tournament.signup_opens_at = DateTime.now
  end
  
  def create
    @tournament = Tournament.new(tournament_params)
    @tournament.auto_schedule_for_multi_day = 0 #default
    @tournament.skip_date_validation = current_user.is_super_user
    
    if @tournament.save
      redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), :flash => { :success => "The tournament was successfully created. Please update course information." }
    else
      initialize_form

      render :new
    end
  end
  
  def touch_tournament
    @tournament.touch
    
    Rails.cache.clear
    
    @tournament.tournament_days.each do |day|
      day.touch
      
      day.tournament_day_results.each do |result|
        result.touch
      end
      
      #day.tournament_day_results.destroy_all #TODO: re-enable as a delayed job thing?
    end
    
    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "Cached data for this tournament was discarded." }
  end

  def edit
  end
  
  def update
    if @tournament.update(tournament_params)
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament was successfully updated." }
    else
      initialize_form
      
      render :edit
    end
  end
  
  def destroy
    @tournament.destroy
    
    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament was successfully deleted." }
  end
  
  #Course Holes
  
  def manage_holes
    @stage_name = "hole_information"
  end

  def update_holes    
    if @tournament.update(tournament_params)
      redirect_to edit_league_tournament_game_types_path(current_user.selected_league, @tournament), :flash => { :success => "The tournament holes were successfully updated. Please select a game type." }
    else
      render :manage_holes
    end
  end
  
  # Signups
  
  def signups
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    @tournament_groups = @tournament_day.tournament_groups.page params[:page]
    
    @available_tournament_groups = []
    @tournament_day.tournament_groups.each do |group|
      @available_tournament_groups << group if group.players_signed_up.count < group.max_number_of_players
    end
    
    @unregistered_users = @tournament.league.users_not_signed_up_for_tournament(@tournament, @tournament_day, [])
    
    @schedule_options = { 0 => "Manual", 1 => "Automatic: Worst Score First", 2 => "Automatic: Best Score First" }
        
    @page_title = "Signups for #{@tournament.name}"
  end
  
  def update_auto_schedule
    if @tournament.update(tournament_params)
      redirect_to league_tournament_signups_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The registration was successfully added." }
    end
  end
  
  def add_signup
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    group = @tournament_day.tournament_groups.where("id = ?", params[:tournament_group_signup][:tee_group]).first
    user = User.find(params[:tournament_group_signup][:another_member_id])
        
    @tournament_day.add_player_to_group(group, user)
    
    redirect_to league_tournament_signups_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The registration was successfully added." }
  end
  
  def delete_signup
    tournament_group = TournamentGroup.find(params[:group_id])
    user = User.find(params[:user_id])
    
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    @tournament_day.remove_player_from_group(tournament_group, user)
    
    redirect_to league_tournament_signups_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The registration was successfully deleted." }
  end
  
  ##
  
  def confirmed_players
    @tournament_day = @tournament.first_day
    @confirmed_players = @tournament.players_for_day(@tournament_day)
  end
  
  ##
  
  def auto_schedule
    groups_error = false
    @tournament.tournament_days.each do |day|
      groups_error = true if day.tournament_groups.count == 0
    end
    
    if groups_error == true
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :error => "One or more days had no tee-times. Re-scheduling was aborted." }
    else
      if @tournament.auto_schedule_for_multi_day != 0
        @tournament.tournament_days.each do |day|
          day.schedule_golfers if day != @tournament.first_day
        end
      end
    
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The days were re-scheduled." }
    end
  end
  
  # Finalize
  
  def finalize
    @page_title = "Finalize Tournament"
    
    if @tournament.can_be_finalized?
      @stage_name = "finalize"
    
      @players = @tournament.players

      @tournament.tournament_days.each do |day|
        day.assign_payouts_from_scores
        
        day.contests.each do |contest|
          contest.score_contest
        end
      end
      
      @tournament.reload
    else
      redirect_to league_tournament_flights_path(current_user.selected_league, @tournament), :flash => { :error => "This tournament requires flights and payouts before it can be finalized." }
    end
  end
  
  def confirm_finalization
    if @tournament.can_be_finalized?
      @tournament.is_finalized = true
      @tournament.save
    
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament was successfully finalized." }
    else
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :error => "The tournament could not be finalized - it is missing required data." }
    end
  end
  
  #Handicaps
  
  def update_course_handicaps
    @tournament.update_course_handicaps
    
    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament's course handicaps were re-calculated." }
  end
  
  private
  
  def set_stage
    @stage_name = "basic_details"
  end
  
  def tournament_params
    params.require(:tournament).permit(:name, :league_id, :dues_amount, :signup_opens_at, :signup_closes_at, :max_players, :show_players_tee_times, :auto_schedule_for_multi_day, tournament_days_attributes: [:id, :course_hole_ids => []])
  end
  
  def fetch_tournament
    unless params[:tournament_id].blank?
      @tournament = Tournament.find(params[:tournament_id])
    else
      @tournament = Tournament.find(params[:id])
    end
  end
  
  def initialize_form        
    if current_user.is_super_user?
      @leagues = League.all.order("name")
    else
      @leagues = current_user.leagues
    end
  end
  
end
