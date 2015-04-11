class TournamentGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_tournament
  before_action :fetch_tournament_group, :except => [:index, :new, :create]
  
  def index
    @tournament_groups = @tournament.tournament_groups.page params[:page]
    
    @page_title = "Tee Times for #{@tournament.name}"
  end
  
  def new
    @tournament_group = TournamentGroup.new
    
    if @tournament.tournament_groups.count > 0
      logger.info { "plus fifteen" }
      
      @tournament_group.tee_time_at = @tournament.tournament_groups.last.tee_time_at + 15.minutes
    else
      logger.info { "tourn" }
      
      @tournament_group.tee_time_at = @tournament.tournament_at
    end
  end
  
  def create
    @tournament_group = TournamentGroup.new(tournament_group_params)
    @tournament_group.tournament = @tournament
    
    if @tournament_group.save      
      redirect_to league_tournament_tournament_groups_path(@tournament.league, @tournament), :flash => { :success => "The tee time was successfully created." }
    else            
      render :new
    end
  end
  
  def update
    if @tournament_group.update(tournament_group_params)
      redirect_to league_tournament_tournament_groups_path(@tournament.league, @tournament), :flash => { :success => "The tee time was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @tournament_group.destroy
    
    redirect_to league_tournament_tournament_groups_path(@tournament.league, @tournament), :flash => { :success => "The tee time was successfully deleted." }
  end
  
  private
  
  def tournament_group_params
    params.require(:tournament_group).permit(:tee_time_at, :max_number_of_players)
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def fetch_tournament_group
    @tournament_group = TournamentGroup.find(params[:id])
  end
end
