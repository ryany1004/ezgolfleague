class Play::ScorecardsController < ApplicationController
  layout "golfer"
  
  before_action :authenticate_user!
  before_action :fetch_scorecard
  
  def show
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
  
  private
  
  def scorecard_params
    params.require(:scorecard).permit(scores_attributes: [:id, :strokes])
  end
  
  def fetch_scorecard
    @scorecard = Scorecard.find(params[:id])
    @tournament = @scorecard.golf_outing.team.tournament_group.tournament
        
    @split_scores = @scorecard.scores.each_slice(@tournament.course_holes.count / 2).to_a
    @split_holes = @tournament.course_holes.each_slice(@tournament.course_holes.count / 2).to_a
  end
  
end
