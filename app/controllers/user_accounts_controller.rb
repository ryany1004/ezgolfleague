class UserAccountsController < ApplicationController
  before_action :authenticate_user!
  
  def index    
    @users = User.page params[:page]
    
    @page_title = "User Accounts"
  end
  
end
