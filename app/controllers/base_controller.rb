class BaseController < ActionController::Base
  layout "application"
  
  before_action :authenticate_user!
end
