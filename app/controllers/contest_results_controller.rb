class ContestResultsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_tournament_day
  before_filter :fetch_contest
  before_filter :fetch_contest_results, :only => [:index]
  before_filter :fetch_contest_result, :only => [:edit, :update, :destroy]
  before_filter :set_stage
  
  def index
    @page_title = "Contest Results"
  end
  
  def new
    @contest_result = ContestResult.new
  end
  
  def create
    @contest_result = ContestResult.new(contest_result_params)
    @contest_result.contest = @contest

    if @contest_result.save
      if @contest.contest_type == 0
        @contest.overall_winner = @contest_result
        @contest.save
      end

      redirect_to league_tournament_contest_contest_results_path(@tournament.league, @tournament, @contest, tournament_day: @tournament_day), :flash => { :success => "The contest result was successfully added." }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @contest_result.update(contest_result_params)      
      redirect_to league_tournament_contest_contest_results_path(@tournament.league, @tournament, @contest, tournament_day: @tournament_day), :flash => { :success => "The contest result was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @contest_result.destroy
    
    redirect_to league_tournament_contest_contest_results_path(@tournament.league, @tournament, @contest, tournament_day: @tournament_day), :flash => { :success => "The contest result was successfully deleted." }
  end
  
  private
  
  def fetch_contest
    @contest = @tournament_day.contests.find(params[:contest_id])
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def fetch_contest_results
    @contest_results = @contest.contest_results
  end
  
  def fetch_contest_result
    @contest_result = ContestResult.find(params[:id])
  end

  def contest_result_params
    params.require(:contest_result).permit(:contest_id, :contest_hole_id, :winner_id, :result_value, :payout_amount, :points)
  end
  
  def fetch_tournament_day
    if params[:tournament_day].blank?
      if params[:tournament_day_id].blank?
        @tournament_day = @tournament.first_day
      else
        @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
      end
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
  end
  
  def set_stage
    if params[:tournament_day].blank?
      if @tournament.tournament_days.count > 1
        @stage_name = "contests#{@tournament.first_day.id}"
      else
        @stage_name = "contests"
      end
    else
      @stage_name = "contests#{@tournament_day.id}"
    end
  end
  
end
