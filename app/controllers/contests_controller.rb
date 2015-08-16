class ContestsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_tournament_day
  before_filter :fetch_contests, :only => [:index]
  before_filter :fetch_contest, :only => [:edit, :update, :destroy]
  before_filter :setup_form, :only => [:new, :edit]
  before_filter :set_stage
  
  def index
    @page_title = "Contests"
  end
  
  def new
    @contest = Contest.new
    @contest.contest_type = 0
  end
  
  def create
    @contest = Contest.new(contest_params)
    @contest.tournament_day = @tournament_day
    
    if @contest.save
      if @contest.contest_type == 1
        if params[:commit] == "Save & Complete Tournament Setup"
          skip_to_completion = true
        else
          skip_to_completion = false
        end
        
        redirect_to edit_league_tournament_contest_path(@tournament.league, @tournament, @contest, :skip_to_complete => skip_to_completion, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully created. Please verify the holes involved." }
      else
        if params[:commit] == "Save & Complete Tournament Setup"
          redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The contest was successfully created." }
        else
          redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully created." }
        end 
      end
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @contest.update(contest_params)    
      if params[:commit] == "Save & Complete Tournament Setup"
        redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The contest was successfully updated." }
      else
        redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully updated." }
      end 
    else      
      render :edit
    end
  end
  
  def destroy
    @contest.destroy
    
    redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully deleted." }
  end
  
  private
  
  def fetch_contests
    @contests = @tournament_day.contests
  end
  
  def fetch_contest
    @contest = @tournament_day.contests.find(params[:id])
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def setup_form  
    @contest_types = []
    @contest_types << ContestType.new("Overall Winner", 0)
    @contest_types << ContestType.new("By Hole", 1)
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
  
  def contest_params
    params.require(:contest).permit(:name, :contest_type, :course_hole_ids => [])
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