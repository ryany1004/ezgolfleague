class Api::V1::TournamentsController < Api::V1::ApiBaseController
  before_action :protect_with_token, except: [:app_association]

  respond_to :json

  def index
    if @current_user.leagues.blank?
      logger.debug { "Current User Has No Leagues" }

      @tournaments = []
    else
      cache_key = self.user_tournaments_cache_key
      @tournaments = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
        logger.info { "Fetching Tournaments - Not Cached for #{cache_key}" }

        todays_tournaments = Tournament.all_today(@current_user.leagues)
        upcoming_tournaments = Tournament.all_upcoming(@current_user.leagues, nil)
        past_tournaments = Tournament.all_past(@current_user.leagues, nil).limit(8).reorder("tournament_starts_at DESC")

        tournaments = todays_tournaments + upcoming_tournaments + past_tournaments
        tournaments = tournaments.select {|t| t.all_days_are_playable? }.to_a #only include tournaments with all playable days
        tournaments = tournaments.uniq

        tournaments
      end
    end
  end

  def results
    tournament = Tournament.find(params[:tournament_id])

    cache_key = "tournament-json#{tournament.id}-#{tournament.updated_at.to_i}"

    @tournament_results = []
    @tournament_results = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
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
          flight.tournament_day_results.each_with_index do |result, i|
            rankings << { flight_number: flight[:flight_number], ranking: result.rank, id: result.user.id, name: result.name, net_score: result.net_score, gross_score: result.gross_score, points: result.points.to_i }
          end
        end        

        #optional_scoring_rules_with_dues
        optional_scoring_rules_with_dues = []
        tournament_presenter.optional_scoring_rules_with_dues.each do |rule|
          optional_scoring_rules_with_dues << { name: rule[:name], winners: rule[:winners] }
        end

        @tournament_results << { payouts: payouts, rankings: rankings, contests: optional_scoring_rules_with_dues }
      end

      @tournament_results
    end

    @uses_scoring_groups = tournament.league.allow_scoring_groups
  end

  def validate_tournaments_exist
    tournament_ids = params[:tournament_ids]
    split_ids = tournament_ids.split(",")

    @invalid_ids = ["0"]

    split_ids.each do |split_id|
      @invalid_ids << split_id if !Tournament.exists?(split_id) || Tournament.find(split_id).league.membership_for_user(@current_user).blank?
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
