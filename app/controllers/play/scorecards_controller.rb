class Play::ScorecardsController < BaseController
  layout "golfer"
  
  before_action :fetch_scorecard, :except => [:update_score, :finalize_scorecard, :become_designated_scorer]
  
  def show
    @page_title = "#{@scorecard.golf_outing.user.complete_name} Scorecard"
  end
  
  def update_score
    @scorecard = Scorecard.find(params[:scorecard_id])
    
    score = Score.find(params[:score_id])
    unless score.blank?
      score.strokes = params[:score][:strokes]
      score.save
    end
    
    redirect_to play_scorecard_path(@scorecard), :flash => { :success => "The scorecard was successfully updated." }
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
    
    @other_scorecards = []
    if @tournament.show_teams? #other scorecards are teammates
      team = @tournament.golfer_team_for_player(@scorecard.golf_outing.user)
      unless team.blank?
        team.users.each do |u|
          @other_scorecards << @tournament.primary_scorecard_for_user(u) if u != @scorecard.golf_outing.user
        end
      
        team_scorecard = @tournament.game_type.team_scorecard_for_team(team)
        @other_scorecards << team_scorecard unless team_scorecard.blank?
      end
    else #other scorecards are group mates
      @tournament.other_group_members(@scorecard.golf_outing.user).each do |player|
        @other_scorecards << @tournament.primary_scorecard_for_user(player)
      end
    end
  end
  
end
