class Play::ScorecardsController < Play::BaseController
  layout 'golfer'

  before_action :fetch_scorecard, except: [:finalize_scorecard, :become_designated_scorer, :update_game_type_metadata]

  def show
    @page_title = "#{@scorecard.golf_outing.user.complete_name} Scorecard"
  end

  def update
    Updaters::ScorecardUpdating.update_scorecards_for_scores(params[:scorecard][:scores]
                               .to_unsafe_h, @scorecard, @scorecards_to_update, false)

    reload_scorecard = @scorecard
    reload_scorecard = Scorecard.find(params[:original_scorecard_id]) if params[:original_scorecard_id].present?

    redirect_to play_scorecard_path(reload_scorecard), flash:
    { success: 'The scorecard was successfully updated.' }
  end

  def finalize_scorecard
    scorecard = Scorecard.find(params[:scorecard_id])
    scorecard.is_confirmed = true
    scorecard.save

    redirect_to play_scorecard_path(scorecard), flash:
    { success: 'The scorecard was successfully finalized.' }
  end

  def become_designated_scorer
    @scorecard = Scorecard.find(params[:scorecard_id])
    @scorecard.designated_editor = current_user
    @scorecard.save

    @tournament_day = @scorecard.golf_outing.tournament_group.tournament_day

    @tournament_day.scorecard_base_scoring_rule.other_group_members(current_user).each do |user|
      scorecard = @tournament_day.primary_scorecard_for_user(user)

      scorecard.designated_editor = current_user
      scorecard.save
    end

    redirect_to play_scorecard_path(@scorecard), flash: { success: 'The scorecard was successfully updated.' }
  end

  def update_game_type_metadata
    @scorecard = Scorecard.find(params[:scorecard_id])

    @scorecard.tournament_day.game_type.update_metadata(params[:metadata])

    redirect_to play_scorecard_path(@scorecard), flash: { success: 'The scorecard was successfully updated.' }
  end

  private

  def scorecard_params
    params.require(:scorecard).permit(scores: [:id, :strokes])
  end

  def fetch_scorecard
    scorecard_info = FetchingTools::ScorecardFetching.fetch_scorecards_and_related(params[:id])

    @tournament_day = scorecard_info[:tournament_day]
    @tournament = scorecard_info[:tournament]

    @scorecard = scorecard_info[:scorecard]
    @other_scorecards = scorecard_info[:other_scorecards]
    @scorecards_to_update = scorecard_info[:scorecards_to_update]

    @scorecard_presenter = ScorecardPresenter.new({ primary_scorecard: @scorecard, secondary_scorecards: @other_scorecards, current_user: current_user })
  end
end
