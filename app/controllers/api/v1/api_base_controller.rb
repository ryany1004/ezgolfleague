class Api::V1::ApiBaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  force_ssl if: :ssl_configured?

  def protect_with_token
    session_token = request.headers["ezgl-token"]
    
    if session_token.blank?
      Rails.logger.debug { "Unauthorized Access" }
      
      response.headers["ezgl-login-error"] = "Login Error"
      
      render text: "Unauthorized access", :status => :bad_request
    else
      @current_user = User.where("session_token = ?", session_token).first
      
      if @current_user.blank?
        Rails.logger.debug { "No such session" }
        
        response.headers["ezgl-login-error"] = "Login Error"
        
        render text: "No such session", :status => :bad_request  
      else
        Rails.logger.debug { "Login Successful" }
      end
    end
  end

  def ssl_configured?
    !Rails.env.development?
  end
  
end