class Api::V1::TournamentDaysController < Api::V1::ApiBaseController
  before_action :protect_with_token
  before_action :fetch_details

  respond_to :json

  def tournament_groups
    @eager_groups = Rails.cache.fetch(@tournament_day.cache_key("groups"), expires_in: 24.hours, race_condition_ttl: 10) do
      logger.info { "Fetching Tournament Day - Not Cached" }

      @tournament_day.eager_groups
    end
  end

  def leaderboard
    @leaderboard = Rails.cache.fetch(@tournament_day.relation_cache_key(@tournament_day.tournament_day_results, "leaderboard-json"), expires_in: 24.hours, race_condition_ttl: 10) do
      logger.info { "Fetching Leaderboard - Not Cached" }

      self.fetch_leaderboard
    end

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

    Rails.cache.delete(@tournament_day.cache_key("groups"))

    @eager_groups = @tournament_day.eager_groups
  end

  def register_contests
    contests = ActiveSupport::JSON.decode(request.body.read)

    contests.each do |c_info|
      contest = Contest.find(c_info)

      contest.add_user(@current_user)
    end

    render json: { success: true }
  end

  def payment_details
    tournament_cost_details = @tournament.cost_breakdown_for_user(@current_user, false, false)

    contest_cost_details = []
    @tournament_day.tournament.tournament_days.each do |td|
      td.contests.each do |c|
        contest_cost_details += c.cost_breakdown_for_user(@current_user, false) if c.dues_amount > 0
      end
    end

    cost_details = {:tournament => tournament_cost_details, :contests => contest_cost_details}

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

    leaderboard = {:day_flights => day_flights_with_rankings, :combined_flights => combined_flights_with_rankings}
  end

end
