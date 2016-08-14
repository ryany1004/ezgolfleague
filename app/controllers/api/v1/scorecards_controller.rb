class Api::V1::ScorecardsController < Api::V1::ApiBaseController
  before_filter :protect_with_token
  before_filter :fetch_details, :only => [:show]

  respond_to :json

  def show
    payload = @tournament_day.scorecard_payload_for_scorecard(@scorecard)

    respond_with(payload) do |format|
      format.json { render :json => payload }
    end
  end

  def current_complication_score
    payload = @current_user.current_watch_complication_score

    respond_with(payload) do |format|
      format.json { render :json => payload }
    end
  end

  #fetches a condensed version of stats for today used by wearables, widgets, etc... optimized for small payload
  def current_day_leaderboard
    Tournament.all_today(@current_user.leagues).each do |t|
      t.tournament_days.each do |d|
        tournament_day = d if d.tournament_at.day == Date.today.day
      end
    end

    unless tournament_day.blank?
      flights_with_rankings = tournament_day.flights_with_rankings

      leaderboard = FetchingTools::LeaderboardFetching.create_slimmed_down_leaderboard(flights_with_rankings)
    end

    respond_with(leaderboard) do |format|
      format.json { render :json => leaderboard }
    end
  end

  def fetch_details
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @scorecard = Scorecard.find(params[:id])
  end

end
