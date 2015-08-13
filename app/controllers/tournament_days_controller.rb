class TournamentDaysController < BaseController
  before_filter :set_stage
  before_filter :initialize_form, :only => [:new, :edit]
  before_filter :fetch_tournament
  before_filter :fetch_tournament_day, :only => [:edit, :update, :destroy]

  def index
  end
  
  def new
    @tournament_day = TournamentDay.new
    @tournament_day.tournament_at = @tournament.signup_closes_at
  end
  
  def create        
    @tournament_day = TournamentDay.new(tournament_day_params)
    @tournament_day.tournament = @tournament
    @tournament_day.game_type_id = 1
    
    @tournament_day.course.course_holes.each do |ch|
      @tournament_day.course_holes << ch
    end
    
    @tournament_day.skip_date_validation = current_user.is_super_user
    
    if @tournament_day.save
      if params[:commit] == "Save & Continue"
        redirect_to league_tournament_manage_holes_path(@tournament.league, @tournament), :flash => { :success => "The day was successfully created." }
      else
        redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), :flash => { :success => "The day was successfully created." }
      end 
    else    
      initialize_form
        
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @tournament_day.update(tournament_day_params)
      redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), :flash => { :success => "The day was successfully updated." }
    else
      initialize_form
      
      render :edit
    end
  end
  
  def destroy
    @tournament_day.destroy
    
    redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), :flash => { :success => "The day was successfully deleted." }
  end
  
  #Course Holes
  
  def manage_holes
    @stage_name = "hole_information"
  end

  def update_holes
    if @tournament.update(tournament_params)
      redirect_to edit_league_tournament_game_types_path(current_user.selected_league, @tournament), :flash => { :success => "The tournament holes were successfully updated. Please select a game type." }
    else
      render :manage_holes
    end
  end
  
  private
  
  def tournament_day_params
    params.require(:tournament_day).permit(:course_id, :tournament_at, :course_hole_ids => [])
  end
  
  def fetch_tournament_day
    @tournament_day = @tournament.tournament_days.find(params[:id])
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def set_stage
    @stage_name = "days"
  end
  
  def initialize_form    
    @courses = Course.all.order("name")
  end
  
end
