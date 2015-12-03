class BaseController < ActionController::Base
  layout "application"
  
  force_ssl if: :ssl_configured?

  def ssl_configured?
    !Rails.env.development?
  end
  
  before_action :authenticate_user!
end
