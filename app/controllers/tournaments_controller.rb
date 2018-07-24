class TournamentsController < BaseController
  helper Play::TournamentsHelper

  before_action :fetch_tournament, :only => [:edit, :update, :destroy, :signups, :manage_holes, :update_holes, :add_signup, :move_signup, :delete_signup, :finalize, :run_finalization, :display_finalization, :debug, :confirm_finalization, :update_course_handicaps, :touch_tournament, :rescore_players, :update_auto_schedule, :auto_schedule, :confirmed_players, :disqualify_signup]
  before_action :initialize_form, :only => [:new, :edit]
  before_action :set_stage

  def index
    if current_user.is_super_user?
      @upcoming_tournaments = Tournament.all_upcoming(nil).page(params[:page]).without_count
      @past_tournaments = Tournament.all_past(nil).reorder("tournament_starts_at DESC").page(params[:page]).without_count
      @unconfigured_tournaments = Tournament.all_unconfigured(nil).page(params[:page]).without_count
    else
      @upcoming_tournaments = Tournament.all_upcoming(current_user.leagues_admin).page(params[:page]).without_count
      @past_tournaments = Tournament.all_past(current_user.leagues_admin).reorder("tournament_starts_at DESC").page(params[:page]).without_count
      @unconfigured_tournaments = Tournament.all_unconfigured(current_user.leagues_admin).page(params[:page]).without_count
    end

    if current_user.is_super_user? || current_user.selected_league&.has_active_subscription? || current_user.selected_league&.free_tournaments_remaining > 0
      @can_create_tournaments = true
    else
      @can_create_tournaments = false
    end

    @page_title = "Tournaments"
  end

  def new
    @tournament = Tournament.new
    @tournament.league = current_user.leagues_admin.first if current_user.leagues_admin.count == 1
    @tournament.signup_opens_at = DateTime.now
  end

  def create
    @tournament = Tournament.new(tournament_params)
    @tournament.auto_schedule_for_multi_day = 0 #default
    @tournament.skip_date_validation = current_user.is_super_user

    if @tournament.save
      league = @tournament.league
      if !league.exempt_from_subscription && league.free_tournaments_remaining > 0
        league.free_tournaments_remaining -= 1 #decrement the free tournaments
        league.save
      end

      redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), :flash => { :success => "The tournament was successfully created. Please update course information." }
    else
      initialize_form

      render :new
    end
  end

  def show
    redirect_to league_tournaments_path(current_user.selected_league)
  end

  ##

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

  ## team stuff

  def options
    tournament_group = TournamentGroup.find(params[:tournament_group_id])

    @golfer_teams = tournament_group.golfer_teams
  end

  #Course Holes

  def manage_holes
    @stage_name = "hole_information"
  end

  def update_holes
    if @tournament.update(tournament_params)
      @tournament.tournament_days.each do |day|
        day.update_scores_for_course_holes
      end

      redirect_to edit_league_tournament_game_types_path(current_user.selected_league, @tournament), :flash => { :success => "The tournament holes were successfully updated. Please select a game type." }
    else
      render :manage_holes
    end
  end

  ##

  def update_auto_schedule
    if @tournament.update(tournament_params)
      redirect_to league_tournament_day_players_path(@tournament.league, @tournament, @tournament.tournament_days.first), :flash => { :success => "The scoring mechanism was updated." }
    end
  end

  def auto_schedule
    groups_error = false
    @tournament.tournament_days.each do |day|
      groups_error = true if day.tournament_groups.count == 0
    end

    if groups_error == true
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :error => "One or more days had no tee-times. Re-scheduling was aborted." }
    else
      @tournament.tournament_days.each do |day|
        AutoscheduleJob.perform_later(day) if day.has_scores? == false
      end
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "Days without scores were submitted to be auto-scheduled. This usually takes a few minutes, depending on the size of the tournament." }
    end
  end

  # Finalize

  def finalize
    @page_title = "Finalize Tournament"

    if @tournament.can_be_finalized?
      @stage_name = "finalize"

      @tournament.run_finalize unless !params[:bypass_calc].blank?

      @tournament_days = @tournament.tournament_days.includes(payout_results: [:flight, :user, :payout], tournament_day_results: [:user, :primary_scorecard], tournament_groups: [golf_outings: [:user, :scorecard]])
    else
      redirect_to league_tournament_flights_path(@tournament.league, @tournament), :flash => { :error => "This tournament cannot be finalized. Verify all flights and payouts exist and if this is a team tournament that all team-members are correctly registered in all contests. Only tournaments with scores can be finalized." }
    end
  end

  def confirm_finalization
    Rails.logger.info { "can_be_finalized?" }
    if @tournament.can_be_finalized?
      if !@tournament.is_finalized
        notification_string = Notifications::NotificationStrings.first_time_finalize(@tournament.name)
      else
        notification_string = Notifications::NotificationStrings.update_finalize(@tournament.name)
      end
      Rails.logger.info { "notify_tournament_users" }
      @tournament.notify_tournament_users(notification_string, { tournament_id: @tournament.id })
      Rails.logger.info { "notify_tournament_users DONE" }

      @tournament.is_finalized = true
      @tournament.save
      Rails.logger.info { "saved finalization" }

      @tournament.finalization_notifications.each do |n|
        n.has_been_delivered = false
        n.save
      end
      Rails.logger.info { "saving finalization notifications" }

      #bust the cache
      @tournament.tournament_days.each do |day|
        day.touch
      end
      Rails.logger.info { "busted cache" }

      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament was successfully finalized." }
    else
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :error => "The tournament could not be finalized - it is missing required data." }
    end
  end

  #Misc

  def touch_tournament
    @tournament.touch

    Rails.cache.clear

    @tournament.tournament_days.each do |day|
      day.touch

      day.tournament_day_results.each do |result|
        result.touch
      end
    end

    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "Cached data for this tournament was discarded." }
  end

  def update_course_handicaps
    @tournament.update_course_handicaps

    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament's course handicaps were re-calculated." }
  end

  def rescore_players
    @tournament.tournament_days.each do |d|
      d.score_users
    end

    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament's scores have been re-calculated." }
  end

  private

  def set_stage
    @stage_name = "basic_details"
  end

  def tournament_params
    params.require(:tournament).permit(:name, :league_id, :dues_amount, :allow_credit_card_payment, :signup_opens_at, :signup_closes_at, :max_players, :show_players_tee_times, :auto_schedule_for_multi_day, tournament_days_attributes: [:id, :course_hole_ids => []])
  end

  def fetch_tournament
    unless params[:tournament_id].blank?
      @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    else
      @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:id])
    end
  end

  def initialize_form
    if current_user.is_super_user?
      @leagues = League.all.order("name")
    else
      @leagues = current_user.leagues.select {|league| league.membership_for_user(current_user).is_admin}
    end
  end

end
