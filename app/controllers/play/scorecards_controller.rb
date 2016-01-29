class Play::ScorecardsController < BaseController
  layout "golfer"
  
  before_action :fetch_scorecard, :except => [:finalize_scorecard, :become_designated_scorer, :update_game_type_metadata]
  
  def show
    @page_title = "#{@scorecard.golf_outing.user.complete_name} Scorecard"
  end
  
  def update    
    UpdatingTools::ScorecardUpdating.update_scorecards_for_scores(params[:scorecard][:scores], @scorecard, @other_scorecards)
    
    logger.info { "SCORE: Re-Scored For Scorecard: #{@scorecard.id}. User: #{@scorecard.golf_outing.user.complete_name}. Net Score: #{@scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => @scorecard.id).first.net_score}" }

    reload_scorecard = @scorecard
    reload_scorecard = Scorecard.find(params[:original_scorecard_id]) unless params[:original_scorecard_id].blank?

    redirect_to play_scorecard_path(reload_scorecard), :flash => { :success => "The scorecard was successfully updated." }
  end
  
  def finalize_scorecard
    scorecard = Scorecard.find(params[:scorecard_id])
    scorecard.is_confirmed = true
    scorecard.save
    
    scorecard.tournament_day.score_user(scorecard.golf_outing.user)
    
    #update team scorecards if that's a thing
    tournament_day = scorecard.golf_outing.tournament_group.tournament_day
    tournament = tournament_day.tournament
    
    if scorecard.designated_editor == current_user && tournament.is_past? == false && tournament_day.game_type.allow_teams != GameTypes::TEAMS_DISALLOWED #in the past, non-team tournament
      logger.info { "Updating Other Scorecards at Finalization" }

      other_scorecards = tournament_day.related_scorecards_for_user(scorecard.golf_outing.user)
      
      other_scorecards.each do |other_scorecard|
        other_scorecard.is_confirmed = true
        other_scorecard.save
        
        scorecard.tournament_day.score_user(other_scorecard.golf_outing.user) unless other_scorecard.golf_outing.blank?
        scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(other_scorecard)
      end
    end
    
    redirect_to play_scorecard_path(scorecard), :flash => { :success => "The scorecard was successfully finalized." }
  end
  
  def become_designated_scorer
    @scorecard = Scorecard.find(params[:scorecard_id])
    @scorecard.designated_editor = current_user
    @scorecard.save
    
    @tournament_day = @scorecard.golf_outing.tournament_group.tournament_day
    
    @tournament_day.other_group_members(current_user).each do |user|
      scorecard = @tournament_day.primary_scorecard_for_user(user)
      
      scorecard.designated_editor = current_user
      scorecard.save
    end
            
    redirect_to play_scorecard_path(@scorecard), :flash => { :success => "The scorecard was successfully updated." }
  end
  
  def update_game_type_metadata
    @scorecard = Scorecard.find(params[:scorecard_id])
    
    @scorecard.tournament_day.game_type.update_metadata(params[:metadata])
    
    redirect_to play_scorecard_path(@scorecard), :flash => { :success => "The scorecard was successfully updated." }
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
    
    @scorecard_presenter = Presenters::ScorecardPresenter.new({primary_scorecard: @scorecard, secondary_scorecards: @other_scorecards, current_user: self.current_user})
  end
  
end
