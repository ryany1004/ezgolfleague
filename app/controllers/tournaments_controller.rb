class TournamentsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_tournament, :only => [:edit, :update, :destroy]
  before_action :initialize_form, :only => [:new, :edit]
  
  def index   
    if current_user.is_super_user?
      @upcoming_tournaments = Tournament.where("tournament_at >= ?", Time.now).page params[:page]
      @past_tournaments = Tournament.where("tournament_at < ?", Time.now).page params[:page]
    else      
      membership_ids = current_user.leagues.map { |n| n.id }
      @upcoming_tournaments = Tournament.joins(:league).where("leagues.id IN (?)", membership_ids).where("tournament_at >= ?", Time.now).page params[:page]
      @past_tournaments = Tournament.joins(:league).where("leagues.id IN (?)", membership_ids).where("tournament_at < ?", Time.now).page params[:page]
    end

    @page_title = "Tournaments"
  end
  
  def new
    @tournament = Tournament.new
  end
  
  def create
    @tournament = Tournament.new(tournament_params)
    
    if @tournament.save
      redirect_to edit_league_tournament_path(@tournament.league, @tournament), :flash => { :success => "The tournament was successfully created." }
    else
      initialize_form

      render :new
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
  
  private
  
  def tournament_params
    params.require(:tournament).permit(:name, :league_id, :course_id, :tournament_at, :signup_opens_at, :signup_closes_at, :max_players, :mens_tee_box, :womens_tee_box, :course_hole_ids => [])
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:id])
  end
  
  def initialize_form    
    @courses = Course.all.order("name")
    @leagues = current_user.leagues
  end
  
end
