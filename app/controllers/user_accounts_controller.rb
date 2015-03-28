class UserAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_user, :only => [:edit, :update, :destroy]
  before_action :initialize_form, :only => [:new, :edit]
  
  def index    
    @user_accounts = User.page params[:page]
    
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
      redirect_to user_accounts_path, :flash => { :success => "The user was successfully updated." }
    else
      initialize_form
      
      render :edit
    end
  end
  
  def destroy
    @user_account.destroy
    
    redirect_to user_accounts_path, :flash => { :success => "The user was successfully deleted." }
  end
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :avatar, :street_address_1, :street_address_2, :city, :us_state, :postal_code, :phone_number, :password, :password_confirmation, :should_invite)
  end
  
  def fetch_user
    @user_account = User.find(params[:id])
  end
  
  def initialize_form    
    @us_states = US_STATES
  end
  
end
