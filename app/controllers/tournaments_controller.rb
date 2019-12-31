class TournamentsController < BaseController
  helper Play::TournamentsHelper

  before_action :fetch_league
  before_action :fetch_tournament, except: [:index, :new]

  def index
    if current_user.selected_league.blank? && current_user.impersonatable_users.blank?
      redirect_to leagues_play_registrations_path, flash: { success: 'Please create or join a league to continue.' }

      return
    end

    @upcoming_tournaments = Tournament.all_upcoming([@league]).page(params[:page]).without_count
    @past_tournaments = Tournament.all_past([@league]).reorder(tournament_starts_at: :desc).page(params[:page]).without_count
    @unconfigured_tournaments = Tournament.all_unconfigured([@league]).page(params[:page]).without_count

    current_user.can_create_tournaments? ? @can_create_tournaments = true : @can_create_tournaments = false

    @page_title = 'Tournaments'
  end

  def new
    if current_user.leagues_admin.count.positive?
      league = current_user.leagues_admin.first
      league.create_missing_next_season
    end
  end

  def show; end

  def edit
    redirect_to league_tournaments_path(current_user.selected_league), flash: { success: 'We could not locate the tournament in question in your account.' } if @tournament.blank?
  end

  def destroy
    league_season = @tournament.league_season

    current_user.send_silent_notification({ action: 'delete', tournament_id: @tournament.id })

    @tournament.destroy

    RankLeagueSeasonJob.perform_later(league_season) if league_season.present?

    redirect_to league_tournaments_path(current_user.selected_league), flash:
    { success: 'The tournament was successfully deleted.' }
  end

  private

  def fetch_league
    if current_user.is_super_user?
      @league = League.find(params[:league_id])
    else
      @league = league_from_user_for_league_id(params[:league_id])
    end
  end

  def fetch_tournament
    valid_tournament_id = fetch_tournament_from_user_for_tournament_id(params[:tournament_id] || params[:id]).id
    @tournament = Tournament.where('id = ?', valid_tournament_id)
                            .includes(tournament_days: [:course, :tournament_groups, :flights, scoring_rules: [:tournament_day_results]])
                            .first
  end
end
