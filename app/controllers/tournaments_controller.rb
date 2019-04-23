class TournamentsController < BaseController
  helper Play::TournamentsHelper

  before_action :fetch_tournament, only: [:show, :edit, :update, :destroy, :signups, :manage_holes, :update_holes, :add_signup, :move_signup, :delete_signup, :debug, :confirm_finalization, :update_course_handicaps, :touch_tournament, :rescore_players, :confirmed_players, :disqualify_signup]
  before_action :initialize_form, only: [:new, :edit]
  before_action :set_stage

  def index
  	redirect_to leagues_play_registrations_path, flash: { success: "Please create or join a league to continue." } and return if current_user.selected_league.blank? && current_user.impersonatable_users.blank?
  	
    @upcoming_tournaments = Tournament.all_upcoming([current_user.current_league]).page(params[:page]).without_count
    @past_tournaments = Tournament.all_past([current_user.current_league]).reorder(tournament_starts_at: :desc).page(params[:page]).without_count    

    if current_user.can_create_tournaments?
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
    @tournament.auto_schedule_for_multi_day = 0 # default
    @tournament.skip_date_validation = current_user.is_super_user

    if @tournament.save
      league = @tournament.league
      if !league.exempt_from_subscription && league.free_tournaments_remaining > 0
        league.free_tournaments_remaining -= 1 # decrement the free tournaments
        league.save
      end

      SendEventToDripJob.perform_later("Created a new tournament", user: current_user, options: { tournament: { name: @tournament.name } })

      redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), flash: { success: "The tournament was successfully created. Please update course information." }
    else
      initialize_form

      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @tournament.update(tournament_params)
      redirect_to league_tournaments_path(current_user.selected_league), flash: { success: "The tournament was successfully updated." }
    else
      initialize_form

      render :edit
    end
  end

  def destroy
  	league_season = @tournament.league_season

    @tournament.destroy

	  RankLeagueSeasonJob.perform_later(league_season) if league_season.present?

    redirect_to league_tournaments_path(current_user.selected_league), flash: { success: "The tournament was successfully deleted." }
  end

  def options
    tournament_group = TournamentGroup.find(params[:tournament_group_id])

    @daily_teams = tournament_group.daily_teams
  end

  def touch_tournament
    @tournament.touch

    Rails.cache.clear

    @tournament.tournament_days.each do |day|
      day.touch

      day.scoring_rules.each do |rule|
      	rule.touch

      	rule.tournament_day_results.each do |result|
      		result.touch
      	end
      end
    end

    redirect_to league_tournaments_path(current_user.selected_league), flash: { success: "Cached data for this tournament was discarded." }
  end

  def update_course_handicaps
    @tournament.update_course_handicaps

    redirect_to league_tournaments_path(current_user.selected_league), flash: { success: "The tournament's course handicaps were re-calculated." }
  end

  def rescore_players
    @tournament.tournament_days.each do |d|
      d.score_all_rules(delete_first: true)
    end

    redirect_to league_tournaments_path(current_user.selected_league), flash: { success: "The tournament's scores have been re-calculated." }
  end

  private

  def set_stage
    @stage_name = "basic_details"
  end

  def tournament_params
    params.require(:tournament).permit(:name, :league_id, :allow_credit_card_payment, :signup_opens_at, :signup_closes_at, :max_players, :show_players_tee_times, :auto_schedule_for_multi_day, tournament_days_attributes: [:id, course_hole_ids: []])
  end

  def fetch_tournament
  	@tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id] || params[:id])
  end

  def initialize_form
    if current_user.is_super_user?
      @leagues = League.all.order(:name)
    else
      @leagues = current_user.leagues.select { |league| league.membership_for_user(current_user).is_admin }
    end
  end

end
