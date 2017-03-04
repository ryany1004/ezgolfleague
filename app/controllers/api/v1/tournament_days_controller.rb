class Api::V1::TournamentDaysController < Api::V1::ApiBaseController
  before_filter :protect_with_token
  before_filter :fetch_details

  respond_to :json

  def tournament_groups
    eager_groups = Rails.cache.fetch(@tournament_day.groups_api_cache_key, expires_in: 2.minute, race_condition_ttl: 10)
    if eager_groups.blank?
      logger.info { "Fetching Tournament Day - Not Cached" }

      eager_groups = TournamentGroup.includes(golf_outings: [:user, course_tee_box: :course_hole_tee_boxes, scorecard: [{scores: :course_hole}]]).where(tournament_day: @tournament_day)

      Rails.cache.write(@tournament_day.groups_api_cache_key, eager_groups)
    else
      logger.info { "Returning Cached Tournament Day Info" }
    end

    respond_with(eager_groups) do |format|
      format.json { render :json => eager_groups }
    end
  end

  def leaderboard
    leaderboard = Rails.cache.fetch(@tournament_day.leaderboard_api_cache_key, expires_in: 2.minute, race_condition_ttl: 10)
    if leaderboard.blank?
      logger.info { "Fetching Leaderboard - Not Cached" }

      leaderboard = self.fetch_leaderboard

      Rails.cache.write(@tournament_day.leaderboard_api_cache_key, leaderboard)
    else
      logger.info { "Returning Cached Leaderboard" }
    end

    respond_with(leaderboard) do |format|
      format.json { render :json => leaderboard }
    end
  end

  def register
    registration_information = ActiveSupport::JSON.decode(request.body.read)

    user = User.find(registration_information["user_id"])
    tournament_group = @tournament_day.tournament_groups.find(registration_information["tournament_group_id"])
    confirm_user = registration_information["confirm_user"]

    @tournament_day.add_player_to_group(tournament_group, user, false, confirm_user)

    Rails.cache.delete(@tournament_day.groups_api_cache_key)

    eager_groups = TournamentGroup.includes(golf_outings: [:user, course_tee_box: :course_hole_tee_boxes, scorecard: [{scores: :course_hole}]]).where(tournament_day: @tournament_day)

    respond_with(eager_groups) do |format|
      format.json { render :json => eager_groups }
    end
  end

  def cancel_registration
    @tournament.tournament_days.each do |day|
      day.tournament_groups.each do |tg|
        tg.golf_outings.each do |outing|
          day.remove_player_from_group(tg, @current_user) if outing.user == @current_user
        end
      end
    end

    Rails.cache.delete(@tournament_day.groups_api_cache_key)

    eager_groups = TournamentGroup.includes(golf_outings: [:user, course_tee_box: :course_hole_tee_boxes, scorecard: [{scores: :course_hole}]]).where(tournament_day: @tournament_day)

    respond_with(eager_groups) do |format|
      format.json { render :json => eager_groups }
    end
  end

  def payment_details
    tournament_cost_details = [@tournament.cost_breakdown_for_user(@current_user, false, false)]

    contest_cost_details = []
    @tournament_day.tournament.tournament_days.each do |td|
      td.contests.each do |c|
        contest_cost_details << c.cost_breakdown_for_user(@current_user, false) if c.dues_amount > 0
      end
    end

    cost_details = {:tournament => tournament_cost_details, :contests => contest_cost_details}

    respond_with(cost_details) do |format|
      format.json { render :json => cost_details }
    end
  end

  def fetch_details
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end

  def fetch_leaderboard
    day_flights_with_rankings = @tournament_day.flights_with_rankings
    combined_flights_with_rankings = FetchingTools::LeaderboardFetching.flights_with_rankings_could_be_combined(@tournament_day, day_flights_with_rankings)

    leaderboard = {:day_flights => day_flights_with_rankings, :combined_flights => combined_flights_with_rankings}
  end

end
