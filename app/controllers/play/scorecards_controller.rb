class Play::ScorecardsController < BaseController
  layout "golfer"
  
  before_action :fetch_scorecard, :except => [:update_score, :finalize_scorecard, :become_designated_scorer, :update_game_type_metadata]
  
  def show
    @page_title = "#{@scorecard.golf_outing.user.complete_name} Scorecard"
  end
    
  def update
    if @scorecard.update(scorecard_params)
      reload_scorecard = @scorecard
      reload_scorecard = Scorecard.find(params[:original_scorecard_id]) unless params[:original_scorecard_id].blank?
      
      redirect_to play_scorecard_path(reload_scorecard), :flash => { :success => "The scorecard was successfully updated." }
    else      
      render :edit
    end
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
    params.require(:scorecard).permit(scores_attributes: [:id, :strokes])
  end
  
  def fetch_scorecard    
    @scorecard = Scorecard.includes(:scores).find(params[:id])
    @tournament = @scorecard.golf_outing.team.tournament_group.tournament
    @other_scorecards = @tournament.related_scorecards_for_user(@scorecard.golf_outing.user)
  end
  
end
