class UserAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_user, :only => [:edit, :update, :destroy]
  before_action :initialize_form, :only => [:new, :edit]
  
  def index
    if current_user.is_super_user?
      @user_accounts = User.page params[:page]
    else
      membership_ids = current_user.leagues.map { |n| n.id }
      @user_accounts = User.joins(:league_memberships).where("league_memberships.league_id IN (?)", membership_ids).page params[:page]
    end
    
    @page_title = "User Accounts"
  end
  
  def new
    @user_account = User.new
  end
  
  def create
    @user_account = User.new(user_params)

    if @user_account.should_invite == "1"
      User.invite!(user_params, current_user)

      redirect_to user_accounts_path, :flash => { :success => "The user was successfully invited." }
    else
      if @user_account.save
        redirect_to user_accounts_path, :flash => { :success => "The user was successfully created." }
      else
        initialize_form

        render :new
      end
    end
  end

  def edit
  end
  
  def update
    if @user_account.update(user_params)
      if @user_account == current_user
        redirect_to root_path
      else
        redirect_to user_accounts_path, :flash => { :success => "The user was successfully updated." }
      end
    else
      initialize_form
      
      render :edit
    end
  end
  
  def destroy
    @user_account.destroy
    
    redirect_to user_accounts_path, :flash => { :success => "The user was successfully deleted." }
  end
  
  # User
  
  def edit_current
    @user_account = current_user
    @editing_current_user = true
  end
  
  # League Admin Invite
  
  def setup_league_admin_invite
    @user_account = User.new
    @leagues = League.all.order("name")
  end
  
  def send_league_admin_invite
    @user_account = User.new(user_params)
    @user_account.password = "temporary_password1234"
    @user_account.password_confirmation = "temporary_password1234"

    if @user_account.save
      @user_account.league_memberships.each do |m|
        m.state = MembershipStates::INVITED
        m.is_admin = true
        m.save
      end
      
      user = User.invite!({:email => @user_account.email}, current_user) do |u|
        u.skip_invitation = true
      end
    
      user.deliver_invitation
    else
      @user_account.errors.each do |e|
        Rails.logger.debug { "#{e}" }
      end
    end

    redirect_to user_accounts_path, :flash => { :success => "The user was successfully invited." }
  end
  
  private
  
  def user_params
    params.require(:user).permit!
  end
  
  def fetch_user
    @user_account = User.find(params[:id])
  end
  
  def initialize_form    
    @us_states = US_STATES
  end
  
end
