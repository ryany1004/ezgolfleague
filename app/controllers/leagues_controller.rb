class LeaguesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_league, :only => [:edit, :update, :destroy]
  
  def index
    if current_user.is_super_user?
      @leagues = League.order("name").page params[:page]
    
      @page_title = "All Leagues"
    else
      @leagues = current_user.leagues.order("name").page params[:page]
    
      @page_title = "My Leagues"
    end
  end
  
  def new
    @league = League.new
  end
  
  def create
    @league = League.new(league_params)
      
    if @league.save      
      redirect_to leagues_path, :flash => { :success => "The league was successfully created." }
    else            
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @league.update(league_params)
      redirect_to leagues_path, :flash => { :success => "The league was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @league.destroy
    
    redirect_to leagues_path, :flash => { :success => "The league was successfully deleted." }
  end
  
  private
  
  def league_params
    params.require(:league).permit(:name)
  end
  
  def fetch_league
    @league = League.find(params[:id])
  end
  
end
