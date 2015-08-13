class TournamentDaysController < BaseController
  before_filter :set_stage
  before_filter :initialize_form, :only => [:new, :edit]
  before_filter :fetch_tournament
  before_filter :fetch_tournament_day, :only => [:edit, :update]

  def index
  end
  
  def new
  end
  
  def create
    #@tournament.skip_date_validation = current_user.is_super_user
    
    # @tournament.course.course_holes.each do |ch|
    #   @tournament.course_holes << ch
    # end
  end
  
  def edit
  end
  
  def update
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
    #params.require(:tournament).permit(:name, :league_id, :course_id, :tournament_at, :dues_amount, :signup_opens_at, :signup_closes_at, :max_players, :show_players_tee_times, :course_hole_ids => [])
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
