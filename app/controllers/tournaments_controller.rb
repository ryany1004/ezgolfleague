class TournamentsController < BaseController
  before_action :fetch_tournament, :only => [:edit, :update, :destroy, :signups, :manage_holes, :update_holes, :delete_signup, :finalize, :confirm_finalization]
  before_action :initialize_form, :only => [:new, :edit]
  
  def index   
    if current_user.is_super_user?
      @upcoming_tournaments = Tournament.where("tournament_at >= ?", Date.today).page params[:page]
      @past_tournaments = Tournament.where("tournament_at < ?", Date.today).page params[:page]
    else      
      membership_ids = current_user.leagues.map { |n| n.id }
      @upcoming_tournaments = Tournament.joins(:league).where("leagues.id IN (?)", membership_ids).where("tournament_at >= ?", Date.today).page params[:page]
      @past_tournaments = Tournament.joins(:league).where("leagues.id IN (?)", membership_ids).where("tournament_at < ?", Date.today).page params[:page]
    end

    @page_title = "Tournaments"
  end
  
  def new
    @tournament = Tournament.new
    @tournament.league = current_user.leagues.first if current_user.leagues.count == 1
  end
  
  def create
    @tournament = Tournament.new(tournament_params)
    @tournament.course.course_holes.each do |ch|
      @tournament.course_holes << ch
    end
    
    if @tournament.save
      redirect_to league_tournament_manage_holes_path(@tournament.league, @tournament), :flash => { :success => "The tournament was successfully created. Please update course information." }
    else
      initialize_form

      render :new
    end
  end
  
  def manage_holes
  end

  def update_holes
    if @tournament.update(tournament_params)
      redirect_to league_tournament_game_types_path(current_user.selected_league, @tournament), :flash => { :success => "The tournament holes were successfully updated. Please select a game type." }
    else
      render :manage_holes
    end
  end

  def edit
  end
  
  def update
    if @tournament.update(tournament_params)
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament was successfully updated." }
    else
      initialize_form
      
      render :edit
    end
  end
  
  def destroy
    @tournament.destroy
    
    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament was successfully deleted." }
  end
  
  # Signups
  
  def signups    
    @tournament_groups = @tournament.tournament_groups.page params[:page]
    
    @page_title = "Signups for #{@tournament.name}"
  end
  
  def delete_signup
    tournament_group = TournamentGroup.find(params[:group_id])
    user = User.find(params[:user_id])
    
    @tournament.remove_player_from_group(tournament_group, user)
    
    redirect_to league_tournament_signups_path(tournament.league, @tournament), :flash => { :success => "The registration was successfully deleted." }
  end
  
  # Finalize
  
  def finalize
    @players = @tournament.players
    
    @tournament.assign_payouts_from_scores
    @payouts = []
    @tournament.flights.each do |f|
      f.payouts.each do |p|
        @payouts << p
      end
    end
  end
  
  def confirm_finalization
    if @tournament.can_be_finalized?
      @tournament.is_finalized = true
      @tournament.save
    
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The tournament was successfully finalized." }
    else
      redirect_to league_tournaments_path(current_user.selected_league), :flash => { :error => "The tournament could not be finalized - it is missing required data." }
    end
  end
  
  private
  
  def tournament_params
    params.require(:tournament).permit(:name, :league_id, :course_id, :tournament_at, :dues_amount, :signup_opens_at, :signup_closes_at, :max_players, :course_hole_ids => [])
  end
  
  def fetch_tournament
    unless params[:tournament_id].blank?
      @tournament = Tournament.find(params[:tournament_id])
    else
      @tournament = Tournament.find(params[:id])
    end
  end
  
  def initialize_form    
    @courses = Course.all.order("name")
    
    if current_user.is_super_user?
      @leagues = League.all.order("name")
    else
      @leagues = current_user.leagues
    end
  end
  
end
