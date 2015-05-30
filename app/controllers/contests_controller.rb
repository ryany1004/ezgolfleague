class ContestsController < BaseController
  before_filter :fetch_tournament
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
    @contest.tournament = @tournament
    
    if @contest.save
      if @contest.contest_type == 1
        if params[:commit] == "Save & Complete Tournament Setup"
          skip_to_completion = true
        else
          skip_to_completion = false
        end
        
        redirect_to edit_league_tournament_contest_path(@tournament.league, @tournament, @contest, :skip_to_complete => skip_to_completion), :flash => { :success => "The contest was successfully created. Please verify the holes involved." }
      else
        if params[:commit] == "Save & Complete Tournament Setup"
          redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The contest was successfully created." }
        else
          redirect_to league_tournament_contests_path(@tournament.league, @tournament), :flash => { :success => "The contest was successfully created." }
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
        redirect_to league_tournament_contests_path(@tournament.league, @tournament), :flash => { :success => "The contest was successfully updated." }
      end 
    else      
      render :edit
    end
  end
  
  def destroy
    @contest.destroy
    
    redirect_to league_tournament_contests_path(@tournament.league, @tournament), :flash => { :success => "The contest was successfully deleted." }
  end
  
  private
  
  def set_stage
    @stage_name = "contests"
  end
  
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