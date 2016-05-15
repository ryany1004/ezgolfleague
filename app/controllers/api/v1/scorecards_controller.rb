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

  def fetch_details
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @scorecard = Scorecard.find(params[:id])
  end

end
