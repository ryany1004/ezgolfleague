class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  impersonates :user

  before_action :remove_blocked_user, if: :current_user

  def remove_blocked_user
    return unless current_user.is_blocked

    sign_out current_user

    redirect_to new_user_session_path
  end
end
