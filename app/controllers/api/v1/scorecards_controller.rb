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
    payload = {}

    Tournament.all_today(@current_user.leagues).each do |t|
      t.tournament_days.each do |td|
        if Time.at(td.tournament_at).to_date === Date.today
          your_results = td.tournament_day_results.where(user: @current_user).first
          winner_result = td.tournament_day_results.first

          payload = {:tournament_id => t.server_id, :tournament_day_id => td.server_id, :your_score => {:score => your_results.net_score, :name => ""}, :top_score => {:score => winner_result.net_score, :name => winner_result.user.short_name}}
        end
      end
    end

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
