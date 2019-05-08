class ApiResultsPresenter
  attr_accessor :tournament
  attr_accessor :user

  def initialize(tournament, user)
    @tournament = tournament
    @user = user
  end

  def individual_results
    tournament_results = []
    @tournament.tournament_days.each do |d|
      tournament_presenter = tournament_presenter(d)

      tournament_results << { payouts: payouts(tournament_presenter),
                              rankings: individual_rankings(tournament_presenter),
                              contests: optional_scoring_rules_with_dues(tournament_presenter) }
    end

    tournament_results
  end

  def league_team_results
    tournament_results = []
    @tournament.tournament_days.each do |d|
      tournament_presenter = tournament_presenter(d)

      tournament_results << { payouts: payouts(tournament_presenter),
                              rankings: individual_rankings(tournament_presenter),
                              contests: optional_scoring_rules_with_dues(tournament_presenter) }
    end

    tournament_results
  end

  private

  def tournament_presenter(day)
    day_flights = day.flights_with_rankings
    combined_flights = FetchingTools::LeaderboardFetching.flights_with_rankings_could_be_combined(day)

    TournamentPresenter.new({ tournament: @tournament,
                              tournament_day: day,
                              user: @user,
                              day_flights: day_flights,
                              combined_flights: combined_flights })
  end

  def payouts(tournament_presenter)
    payouts = []
    tournament_presenter.payouts.each do |p|
      payouts << { flight_number: p[:flight_number],
                   name: p[:name],
                   id: p[:user_id],
                   amount: p[:amount].to_f,
                   points: p[:points],
                   matchup_position: p[:matchup_position] }
    end

    payouts
  end

  def individual_rankings(tournament_presenter)
    rankings = []
    tournament_presenter.flights_with_rankings.each do |flight|
      flight.tournament_day_results.each do |result|
        rankings << { flight_number: flight[:flight_number],
                      ranking: result.rank,
                      id: result.user.id,
                      name: result.name,
                      net_score: result.net_score,
                      gross_score: result.gross_score,
                      points: result.points.to_i,
                      matchup_position: result.matchup_position }
      end
    end

    rankings
  end

  def optional_scoring_rules_with_dues(tournament_presenter)
    optional_scoring_rules_with_dues = []
    tournament_presenter.optional_scoring_rules_with_dues.each do |rule|
      optional_scoring_rules_with_dues << { name: rule[:name], winners: rule[:winners] }
    end

    optional_scoring_rules_with_dues
  end
end
