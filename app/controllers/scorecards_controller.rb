class ScorecardsController < BaseController
  before_action :fetch_all_params, :only => [:edit]
  before_action :fetch_scorecard, :only => [:show, :update]
  before_action :repair_scorecard, :only => [:show, :edit]

  def index
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end

    @page_title = "Scorecards"

    @eager_groups = fetch_eager_groups
  end

  def show
    eager_groups = fetch_eager_groups

    @next_scorecard = find_next_scorecard(@tournament_day, eager_groups, @scorecard)
  end

  def edit
    redirect_to root_path if !@scorecard.user_can_edit?(current_user)

    eager_groups = fetch_eager_groups

    @next_scorecard = find_next_scorecard(@tournament_day, eager_groups, @scorecard)
  end

  def update
    #handicap update
    @scorecard.update(scorecard_params)

    #scores
    scores_to_update = Hash.new

    params[:scorecard][:scores_attributes].to_unsafe_h.keys.each do |key|
      score_id = params[:scorecard][:scores_attributes][key]["id"]
      strokes = params[:scorecard][:scores_attributes][key]["strokes"]

      scores_to_update[score_id] = {:strokes => strokes}
    end

    logger.debug { "Sending: #{scores_to_update}" }

    Updaters::ScorecardUpdating.update_scorecards_for_scores(scores_to_update, @scorecard, @scorecards_to_update)

    redirect_to edit_scorecard_path(@scorecard), flash: { :alert => "The scorecard was successfully updated. NOTE: Net scores are calculated in the background and may not be immediately up to date." }
  end

  def disqualify
    @scorecard = Scorecard.find(params[:scorecard_id])
    @player = @scorecard.golf_outing.user
    @tournament_day = @scorecard.golf_outing.tournament_group.tournament_day

    golf_outing = @tournament_day.golf_outing_for_player(@player)
    golf_outing.disqualify

    redirect_to edit_scorecard_path(@scorecard), flash: { :alert => "The scorecard disqualification was toggled." }
  end

  def fetch_eager_groups
    TournamentGroup.includes(golf_outings: [{scorecard: :scores}, :user]).where(tournament_day: @tournament_day).order(:tee_time_at)
  end

  def repair_scorecard
    @scorecard.tournament_day.update_scores_for_scorecard(@scorecard) if !@scorecard.tournament_day.has_scores?
  end

  def find_next_scorecard(tournament_day, groups, current_scorecard)
    next_scorecard = nil

    sorted_players = []
    groups.each do |group|
      group.players_signed_up.each do |player|
        sorted_players << player
      end
    end

    sorted_players.each_with_index do |player, i|
      if player == current_scorecard.golf_outing.user
        next_golfer = sorted_players[i + 1]

        next_scorecard = tournament_day.primary_scorecard_for_user(next_golfer) unless next_golfer.blank?
      end
    end

    next_scorecard
  end

  private

  def scorecard_params
    params.require(:scorecard).permit(scores_attributes: [:id, :strokes], golf_outing_attributes: [:id, :course_handicap])
  end

  def fetch_all_params
    @scorecard = Scorecard.find(params[:id])
    @player = @scorecard.golf_outing.user
    @tournament_day = @scorecard.golf_outing.tournament_group.tournament_day
    @tournament = @tournament_day.tournament
    @handicap_allowance = @tournament_day.handicap_allowance(@scorecard.golf_outing.user)
  end

  def fetch_scorecard
    scorecard_info = FetchingTools::ScorecardFetching.fetch_scorecards_and_related(params[:id])

    @tournament_day = scorecard_info[:tournament_day]
    @tournament = scorecard_info[:tournament]

    @scorecard = scorecard_info[:scorecard]
    @other_scorecards = scorecard_info[:other_scorecards]
    @scorecards_to_update = scorecard_info[:scorecards_to_update]

    @scorecard_presenter = ScorecardPresenter.new({primary_scorecard: @scorecard, secondary_scorecards: @other_scorecards, current_user: self.current_user})

    redirect_to root_path if !@scorecard.user_can_view?(current_user)
  end

end
