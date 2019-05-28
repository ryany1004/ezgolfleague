class Api::V1::TournamentDaysController < Api::V1::ApiBaseController
  before_action :protect_with_token
  before_action :fetch_details

  respond_to :json

  def tournament_groups
    @eager_groups = Rails.cache.fetch(@tournament_day.cache_key('groups'), expires_in: 1.hour, race_condition_ttl: 10) do
      logger.info { 'Fetching Tournament Day - Not Cached' }

      @tournament_day.eager_groups
    end

    fresh_when @tournament_day
  end

  def leaderboard
    @leaderboard = fetch_leaderboard

    @day_flights = @leaderboard[:day_flights]
    @combined_flights = @leaderboard[:combined_flights]
  end

  def register
    registration_information = ActiveSupport::JSON.decode(request.body.read)

    logger.info { "API Registration Details: #{registration_information}" }

    user = User.find(registration_information["user_id"])
    tournament_group = @tournament_day.tournament_groups.find(registration_information["tournament_group_id"])
    confirm_user = registration_information["confirm_user"]

    @tournament_day.add_player_to_group(tournament_group: tournament_group, user: user, paying_with_credit_card: false, confirmed: confirm_user, registered_by: "App: #{user.complete_name}")

    Rails.cache.delete(@tournament_day.cache_key("groups"))

    TournamentMailer.tournament_player_paying_later(user, @tournament_day.tournament).deliver_later if confirm_user == false

    eager_groups = @tournament_day.eager_groups

    respond_with(eager_groups) do |format|
      format.json { render json: eager_groups }
    end
  end

  def cancel_registration
    @tournament.tournament_days.each do |day|
      day.tournament_groups.each do |tg|
        tg.golf_outings.each do |outing|
          day.remove_player_from_group(tournament_group: tg, user: @current_user) if outing.user == @current_user
        end
      end
    end

    TournamentMailer.tournament_player_cancelled(@current_user, @tournament).deliver_later

    Rails.cache.delete(@tournament_day.cache_key('groups'))

    @eager_groups = @tournament_day.eager_groups

    render json: { success: true }
  end

  def register_contests
    register_optional_games
  end

  def register_optional_games
    payload = ActiveSupport::JSON.decode(request.body.read)

    payload.each do |p|
      scoring_rule = @tournament_day.scoring_rules.find(p)

      scoring_rule.users << @current_user unless scoring_rule.users.include? @current_user
    end

    render json: { success: true }
  end

  def payment_details
    tournament_cost_details = @tournament.cost_breakdown_for_user(user: @current_user, include_unpaid_optional_rules: false, include_credit_card_fees: false)

    optional_rules_cost_details = []
    @tournament.optional_scoring_rules_with_dues.each do |r|
      optional_rules_cost_details += r.cost_breakdown_for_user(user: @current_user, include_credit_card_fees: false)
    end

    cost_details = { tournament: tournament_cost_details, contests: optional_rules_cost_details }

    respond_with(cost_details) do |format|
      format.json { render json: cost_details }
    end
  end

  def fetch_details
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end

  def fetch_leaderboard
    day_flights_with_rankings = @tournament_day.flights_with_rankings
    combined_flights_with_rankings = FetchingTools::LeaderboardFetching.flights_with_rankings_could_be_combined(@tournament_day)

    { day_flights: day_flights_with_rankings, combined_flights: combined_flights_with_rankings }
  end
end
