class Api::V1::TournamentsController < Api::V1::ApiBaseController
  before_action :protect_with_token, except: [:app_association]

  respond_to :json

  def index
    if @current_user.leagues.blank?
      logger.debug { 'Current User Has No Leagues' }

      @tournaments = []
    else
      cache_key = user_tournaments_cache_key
      @tournaments = Rails.cache.fetch(cache_key, expires_in: 8.hours, race_condition_ttl: 10) do
        logger.info { "Fetching Tournaments - Not Cached for #{cache_key}" }

        todays_tournaments = Tournament.all_today(@current_user.leagues).includes(:league, tournament_days: [:course, scoring_rules: :payments])
        upcoming_tournaments = Tournament.all_upcoming(@current_user.leagues, nil).includes(:league, tournament_days: [:course, scoring_rules: :payments])
        past_tournaments = Tournament.all_past(@current_user.leagues, nil).limit(12).reorder(tournament_starts_at: :desc).includes(:league, tournament_days: [:course, scoring_rules: :payments])

        tournaments = todays_tournaments + upcoming_tournaments + past_tournaments
        tournaments = tournaments.select(&:all_days_are_playable?).to_a
        tournaments = tournaments.uniq

        tournaments
      end
    end

    fresh_when @tournaments
  end

  def results
    @tournament = Tournament.find(params[:tournament_id])
    @uses_scoring_groups = @tournament.league.allow_scoring_groups

    results_presenter = ApiResultsPresenter.new(@tournament, current_user)

    if @tournament.has_league_season_team_scoring_rules?
      cache_key = "tournament-teams-json#{@tournament.id}-#{@tournament.updated_at.to_i}"
      @tournament_results = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
        results_presenter.league_team_results
      end
    else
      cache_key = "tournament-individual-json#{@tournament.id}-#{@tournament.updated_at.to_i}"
      @tournament_results = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
        results_presenter.individual_results
      end
    end
  end

  def validate_tournaments_exist
    tournament_ids = params[:tournament_ids]
    split_ids = tournament_ids.split(',')

    @invalid_ids = ['0']

    split_ids.each do |split_id|
      @invalid_ids << split_id if !Tournament.exists?(split_id) || Tournament.find(split_id).league.membership_for_user(@current_user).blank?
    end
  end

  def app_association
    render json: {
      webcredentials: {
        apps: ['9F3JLFC8C4.com.ezgolfleague.GolfApp']
      }
    }
  end

  def user_tournaments_cache_key
    max_updated_at_upcoming = Tournament.all_upcoming(@current_user.leagues, nil).maximum(:updated_at).try(:utc).try(:to_s, :number)
    max_updated_at_past = Tournament.all_past(@current_user.leagues, nil).maximum(:updated_at).try(:utc).try(:to_s, :number)
    max_updated_at_today = Tournament.all_today(@current_user.leagues).maximum(:updated_at).try(:utc).try(:to_s, :number)

    "APITournaments-#{@current_user.id}-#{max_updated_at_upcoming}-#{max_updated_at_past}-#{max_updated_at_today}"
  end
end
