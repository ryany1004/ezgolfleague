class Api::V1::ScorecardsController < Api::V1::ApiBaseController
  before_action :protect_with_token
  before_action :fetch_details, only: [:show]

  respond_to :json

  def show
    if @scorecard.blank?
      Rails.logger.info { "API Scorecard Call Nil #{params[:id]}" }

      render nothing: true, status: 404
    else
      payload = @tournament_day.scorecard_payload_for_scorecard(@scorecard)

      respond_with(payload) do |format|
        format.json { render json: payload }
      end
    end
  end

  #fetches a condensed version of stats for today used by wearables, widgets, etc... optimized for small payload
  def current_day_leaderboard
    tournament_day = nil

    Tournament.all_today(@current_user.leagues).each do |t|
      t.tournament_days.each do |d|
        tournament_day = d if d.tournament_at.day == Date.current.in_time_zone.day
      end

      tournament_day = t.tournament_days.first if tournament_day.blank?
    end

    unless tournament_day.blank?
      leaderboard = FetchingTools::LeaderboardFetching.create_slimmed_down_leaderboard(tournament_day)
    end

    respond_with(leaderboard) do |format|
      format.json { render json: leaderboard }
    end
  end

  def fetch_details
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @scorecard = Scorecard.where(id: params[:id]).first
  end

end
