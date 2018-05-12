class Api::V1::TournamentsController < Api::V1::ApiBaseController
  before_action :protect_with_token, except: [:app_association]

  respond_to :json

  def index
    if @current_user.leagues.blank?
      all_tournaments = []
    else
      cache_key = self.user_tournaments_cache_key
      all_tournaments = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
        logger.info { "Fetching Tournaments - Not Cached for #{cache_key}" }

        todays_tournaments = Tournament.all_today(@current_user.leagues)
        upcoming_tournaments = Tournament.all_upcoming(@current_user.leagues, nil)
        past_tournaments = Tournament.all_past(@current_user.leagues, nil).limit(15).reorder("tournament_starts_at DESC")

        all_tournaments = todays_tournaments + upcoming_tournaments + past_tournaments
        all_tournaments = all_tournaments.select {|t| t.all_days_are_playable? }.to_a #only include tournaments with all playable days
        all_tournaments = all_tournaments.uniq

        all_tournaments
      end
    end

    respond_with(all_tournaments) do |format|
      format.json { render :json => all_tournaments, content_type: 'application/json' }
    end
  end

  def results
    tournament = Tournament.find(params[:tournament_id])

    cache_key = "tournament-json#{tournament.id}-#{tournament.updated_at.to_i}"

    tournament_results = []
    tournament_results = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
      tournament.tournament_days.each do |d|
        day_flights = d.flights_with_rankings
        combined_flights = FetchingTools::LeaderboardFetching.flights_with_rankings_could_be_combined(d)
        tournament_presenter = TournamentPresenter.new({tournament: tournament, tournament_day: d, user: current_user, day_flights: day_flights, combined_flights: combined_flights})

        #payouts
        payouts = []
        tournament_presenter.payouts.each_with_index do |f, x|
          f[:payouts].each do |p|
            payouts << { flight_number: p[:flight_number], name: p[:name], id: p[:user_id], amount: p[:amount].to_f, points: p[:points] }
          end
        end

        #rankings
        rankings = []
        tournament_presenter.flights_with_rankings.each_with_index do |flight, x|
          flight[:players].each_with_index do |player, i|
            rankings << { flight_number: flight[:flight_number], ranking: player[:ranking], id: player[:id], name: player[:name], net_score: player[:net_score], gross_score: player[:gross_score], points: player[:points].to_i }
          end
        end        

        #contests
        contests = []
        tournament_presenter.contests.each do |contest|
          contests << { name: contest[:name], winners: contest[:winners] }
        end

        tournament_results << { payouts: payouts, rankings: rankings, contests: contests }
      end

      tournament_results
    end

    uses_scoring_groups = tournament.league.allow_scoring_groups

    respond_with(tournament_results) do |format|
      format.json { render :json => {tournament_day_results: tournament_results, uses_scoring_groups: uses_scoring_groups}, content_type: 'application/json' }
    end
  end

  def validate_tournaments_exist
    tournament_ids = params[:tournament_ids]
    split_ids = tournament_ids.split(",")

    invalid_ids = ["0"]

    split_ids.each do |split_id|
      invalid_ids << split_id if !Tournament.exists?(split_id) || Tournament.find(split_id).league.membership_for_user(@current_user).blank?
    end

    respond_with(invalid_ids) do |format|
      format.json { render :json => invalid_ids, content_type: 'application/json' }
    end
  end

  def app_association
    render json: {
      webcredentials: {
        apps: ["9F3JLFC8C4.com.ezgolfleague.GolfApp"]
      }
    }
  end

  def user_tournaments_cache_key
    max_updated_at = Tournament.all_upcoming(@current_user.leagues, nil).maximum(:updated_at).try(:utc).try(:to_s, :number)

    return "APITournaments-#{@current_user.id}-#{max_updated_at}"
  end

  def format_tournament_group_tee_time(tournament_group)
    if tournament_group.tournament_day.tournament.show_players_tee_times == true
      return tournament_group.tee_time_at.to_s(:time_only)
    else
      return tournament_group.time_description
    end
  end

end
