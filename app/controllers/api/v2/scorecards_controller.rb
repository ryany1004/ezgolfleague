class Api::V2::ScorecardsController < BaseController
  before_action :fetch_scorecard, only: [:update]

  respond_to :json

  def show
    scorecard_info = FetchingTools::ScorecardFetching.fetch_scorecards_and_related(params[:id])

    @tournament_day = scorecard_info[:tournament_day]
    @tournament = scorecard_info[:tournament]

    @scorecard = scorecard_info[:scorecard]
    @other_scorecards = scorecard_info[:other_scorecards]
    @scorecards_to_update = scorecard_info[:scorecards_to_update]

    @scorecard_presenter = ScorecardPresenter.new({ primary_scorecard: @scorecard, secondary_scorecards: @other_scorecards, current_user: current_user })

    render json: { error: 'Unauthorized Scorecard' }, status: :unauthorized unless @scorecard.user_can_view?(current_user)
  end

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)

    scores_to_update = {}

    payload['scorecards'].each do |card_data|
      card_data['scores'].each do |score_data|
        scores_to_update[score_data['id']] = { strokes: score_data['score'] }
      end
    end

    Updaters::ScorecardUpdating.update_scorecards_for_scores(scores_to_update, @scorecard, @scorecards_to_update)

    primary_scorecard = payload['scorecards'].first
    course_handicap = primary_scorecard['course_handicap']
    Scorecard.find(primary_scorecard['id']).golf_outing.update(course_handicap: course_handicap)

    render json: :ok
  end

  private

  def fetch_scorecard
    scorecard_info = FetchingTools::ScorecardFetching.fetch_scorecards_and_related(params[:id])

    @tournament_day = scorecard_info[:tournament_day]
    @tournament = scorecard_info[:tournament]

    @scorecard = scorecard_info[:scorecard]
    @other_scorecards = scorecard_info[:other_scorecards]
    @scorecards_to_update = scorecard_info[:scorecards_to_update]

    @scorecard_presenter = ScorecardPresenter.new({ primary_scorecard: @scorecard, secondary_scorecards: @other_scorecards, current_user: current_user })

    if @scorecard.user_can_view?(current_user)
      @scorecard_presenter
    else
      nil
    end
  end
end
