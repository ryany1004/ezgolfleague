class Play::ScorecardsController < BaseController
  layout "golfer"
  
  before_action :fetch_scorecard, :except => [:finalize_scorecard, :become_designated_scorer, :update_game_type_metadata]
  
  def show
    @page_title = "#{@scorecard.golf_outing.user.complete_name} Scorecard"
  end
  
  def update
    params[:scorecard][:scores].each do |score_param|
      logger.info { "#{score_param}" }
      
      score_id = score_param[0].to_i
      strokes = score_param[1][:strokes]
      
      logger.info { "#{score_id} #{strokes}" }
      
      score = Score.find(score_id)
      score.strokes = strokes
      score.save
    end

    @scorecard.tournament.game_type.after_updating_scores_for_scorecard(@scorecard)

    reload_scorecard = @scorecard
    reload_scorecard = Scorecard.find(params[:original_scorecard_id]) unless params[:original_scorecard_id].blank?

    redirect_to play_scorecard_path(reload_scorecard), :flash => { :success => "The scorecard was successfully updated." }
  end
  
  def finalize_scorecard
    scorecard = Scorecard.find(params[:scorecard_id])
    scorecard.is_confirmed = true
    scorecard.save
    
    redirect_to play_scorecard_path(scorecard), :flash => { :success => "The scorecard was successfully finalized." }
  end
  
  def become_designated_scorer
    @scorecard = Scorecard.find(params[:scorecard_id])
    @scorecard.designated_editor = current_user
    @scorecard.save
    
    @tournament = @scorecard.golf_outing.team.tournament_group.tournament
    
    @tournament.other_group_members(current_user).each do |user|
      scorecard = @tournament.primary_scorecard_for_user(user)
      
      scorecard.designated_editor = current_user
      scorecard.save
    end
            
    redirect_to play_scorecard_path(@scorecard), :flash => { :success => "The scorecard was successfully updated." }
  end
  
  def update_game_type_metadata
    @scorecard = Scorecard.find(params[:scorecard_id])
    
    @scorecard.tournament.game_type.update_metadata(params[:metadata])
    
    redirect_to play_scorecard_path(@scorecard), :flash => { :success => "The scorecard was successfully updated." }
  end
  
  private
  
  def scorecard_params
    # params.require(:scorecard).permit(scores_attributes: [:id, :strokes])
    params.require(:scorecard).permit(scores: [:id, :strokes])
  end
  
  def fetch_scorecard    
    @scorecard = Scorecard.includes(:scores).find(params[:id])
    @tournament = @scorecard.golf_outing.team.tournament_group.tournament
    
    if @tournament.is_past? && @tournament.game_type.allow_teams == GameTypes::TEAMS_DISALLOWED #in the past, non-team tournament
      @other_scorecards = []
    else
      @other_scorecards = @tournament.related_scorecards_for_user(@scorecard.golf_outing.user)
    end
  end
  
end
