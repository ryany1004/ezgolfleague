class ContestsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_contests, :only => [:index]
  before_filter :fetch_contest, :only => [:edit, :update, :destroy]
  before_filter :setup_form, :only => [:new, :edit]
  
  def index
    @page_title = "Contests"
  end
  
  def new
    @contest = Contest.new
    @contest.contest_type = 0
  end
  
  def create
    @contest = Contest.new(contest_params)
    @contest.tournament = @tournament
    
    if @contest.save
      redirect_to edit_league_tournament_contest_path(@tournament.league, @tournament, @contest), :flash => { :success => "The contest was successfully created." }
    else
      render :new
    end
  end
  
  def edit
    @contest.build_overall_winner if @contest.overall_winner.blank?
  end
  
  def update
    if @contest.update(contest_params)
      redirect_to league_tournament_contests_path(@tournament.league, @tournament), :flash => { :success => "The contest was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @contest.destroy
    
    redirect_to league_tournament_contests_path(@tournament.league, @tournament), :flash => { :success => "The contest was successfully deleted." }
  end
  
  private
  
  def fetch_contests
    @contests = @tournament.contests
  end
  
  def fetch_contest
    @contest = @tournament.contests.find(params[:id])
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def setup_form  
    @contest_types = []
    @contest_types << ContestType.new("Overall Winner", 0)
    @contest_types << ContestType.new("By Hole", 1)
  end
  
  def contest_params
    params.require(:contest).permit(:name, :contest_type, overall_winner_attributes: [:contest_id, :winner_id, :result_value, :payout_amount])
  end
  
end

class ContestType
  attr_accessor :name
  attr_accessor :value
  
  def initialize(name, value)
    @name = name
    @value = value
  end
end