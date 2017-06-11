class PrintsController < ApplicationController
  before_action :fetch_tournament_details
  
  def print_scorecards
  end
 
  def run_print_scorecards
    @job = Delayed::Job.enqueue PrintScorecardsJob.new(@tournament_day, current_user)
    
    @display_path = print_display_scorecards_prints_path(tournament_day: @tournament_day, tournament_id: @tournament)
  end
 
  def print_display_scorecards
    @content = Rails.cache.read(@tournament_day.scorecard_print_cache_key)
    
    @content = "There was an error rendering scorecards. Please go back and try again." if @content.blank?
    
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
