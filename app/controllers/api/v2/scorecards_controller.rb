class Api::V2::ScorecardsController < BaseController
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
end
