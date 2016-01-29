class PrintsController < ApplicationController
  before_filter :fetch_tournament_details
  
  def print_scorecards
  end
 
  def run_print_scorecards
    @job = Delayed::Job.enqueue PrintScorecardsJob.new(@tournament_day, current_user)
    
    @display_path = print_display_scorecards_prints_path(tournament_day: @tournament_day, tournament_id: @tournament)
    
    logger.info { "#{@display_path}" }
  end
 
  def print_display_scorecards
    render layout: false
  end
  
  def fetch_tournament_details
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
  end
  
end
