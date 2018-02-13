class Api::V1::ApiBaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  around_action :user_time_zone, if: :current_user

  force_ssl if: :ssl_configured?

  def protect_with_token
    session_token = request.headers["ezgl-token"]

    if session_token.blank?
      Rails.logger.info { "API: Unauthorized Access" }

      response.headers["ezgl-login-error"] = "Login Error"

      render text: "Unauthorized access", :status => :unauthorized
    else
      @current_user = User.where("session_token = ?", session_token).first

      if @current_user.blank?
        Rails.logger.info { "API: No Such Session" }

        response.headers["ezgl-login-error"] = "Login Error"

        render text: "No such session", :status => :unauthorized
      else
        sign_in(@current_user, :bypass => true)

        Rails.logger.info { "API: Login Successful for #{@current_user.id}" }
      end
    end
  end

  def assign_user_session_token(user)
    user.session_token = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    user.save
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def ssl_configured?
    !Rails.env.development?
  end
end
