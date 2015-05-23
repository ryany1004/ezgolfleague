class Play::ScorecardsController < BaseController
  layout "golfer"
  
  before_action :fetch_scorecard, :except => [:finalize_scorecard, :become_designated_scorer]
  
  def show
    @page_title = "#{@scorecard.golf_outing.user.complete_name} Scorecard"
  end
  
  def edit
  end
  
  def update
    if @scorecard.update(scorecard_params)
      redirect_to play_scorecard_path(@scorecard), :flash => { :success => "The scorecard was successfully updated." }
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
  
  private
  
  def scorecard_params
    params.require(:scorecard).permit(scores_attributes: [:id, :strokes])
  end
  
  def fetch_scorecard
    @scorecard = Scorecard.find(params[:id])
    @tournament = @scorecard.golf_outing.team.tournament_group.tournament
    @handicap_allowance = @tournament.handicap_allowance(@scorecard.golf_outing.user)
    
    @split_scores = @scorecard.scores.each_slice(@tournament.course_holes.count / 2).to_a
    @split_holes = @tournament.course_holes.each_slice(@tournament.course_holes.count / 2).to_a
  end
  
end
