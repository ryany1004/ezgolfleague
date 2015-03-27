class LeagueMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_membership, :only => [:edit, :update, :destroy]
  before_action :fetch_league
  before_action :fetch_users, :only => [:edit, :new]
  
  def index 
    @league_memberships = LeagueMembership.order("created_at DESC").page params[:page]
    
    @page_title = "League Memberships"
  end
  
  def new
    @league_membership = LeagueMembership.new
  end
  
  def create
    @league_membership = LeagueMembership.new(membership_params)
    @league_membership.league = @league
    
    if @league_membership.save      
      redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully created." }
    else            
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @league_membership.update(membership_params)
      redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @league_membership.destroy
    
    redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully deleted." }
  end
  
  private
  
  def membership_params
    params.require(:league_membership).permit(:user, :user_id, :league, :is_admin)
  end
  
  def fetch_membership
    @league_membership = LeagueMembership.find(params[:id])
  end
  
  def fetch_league
    @league = League.find(params[:league_id])
  end
  
  def fetch_users
    @users = User.all.order("last_name").order("first_name").order("created_at DESC")
  end
  
end
