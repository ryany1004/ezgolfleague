class PrintsController < ApplicationController
  
  def print_scorecards
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end

    #@print_cards = [] #TODO: REMOVE
    
    # @print_cards = []
    #
    # @tournament.players_for_day(@tournament_day).each do |player|
    #   primary_scorecard = @tournament_day.primary_scorecard_for_user(player)
    #   other_scorecards = @tournament_day.related_scorecards_for_user(player, true)
    #
    #   if other_scorecards.count < 4
    #     number_to_create = (4 - other_scorecards.count) - 1
    #
    #     number_to_create.times do
    #       extra_scorecard = GameTypes::EmptyLineScorecard.new
    #       extra_scorecard.scores_for_course_holes(@tournament_day.course_holes)
    #
    #       other_scorecards << extra_scorecard
    #     end
    #   end
    #
    #   scorecard_presenter = Presenters::ScorecardPresenter.new({primary_scorecard: primary_scorecard, secondary_scorecards: other_scorecards})
    #
    #   @print_cards << {p: scorecard_presenter} if !self.printable_cards_includes_player?(@print_cards, player)
    # end
    #
    # render layout: false
  end
 
  def run_print_scorecards
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    @job = Delayed::Job.enqueue PrintScorecardsJob.new(@tournament_day)
    
    @display_path = print_display_scorecards_prints_path(:tournament_id => @tournament, tournament_day: @tournament_day)
  end
 
  def print_display_scorecards
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    render layout: false
  end
  
end
