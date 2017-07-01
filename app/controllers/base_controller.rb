class BaseController < ActionController::Base
  layout "application"

  force_ssl if: :ssl_configured?

  def ssl_configured?
    !Rails.env.development?
  end

  before_action :authenticate_user!
  around_action :user_time_zone, if: :current_user

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  impersonates :user
end
