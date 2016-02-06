class ReportsController < ApplicationController
  before_filter :fetch_tournament_day, except: [:index]

  def index
    leagues = nil
    leagues = current_user.leagues unless current_user.is_super_user?
    
    @past_tournaments = Tournament.all_past(leagues).page params[:page]

    @page_title = "Tournament Reports"
  end
  
  def adjusted_scores
    @report = Reports::AdjustedScores.new(@tournament_day)
    
    @page_title = "Adjusted Score Report"
  end

  def fetch_tournament_day
    @tournament = Tournament.find(params[:tournament])
    
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
  end

end
