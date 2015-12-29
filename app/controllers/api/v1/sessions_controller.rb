class Api::V1::SessionsController < Api::V1::ApiBaseController
  
  def create
    email = request.headers["ezgl-email"]
    password = request.headers["ezgl-password"]

    if email.blank? or password.blank?
      render text: "Missing Data", :status => :bad_request
    else
      user = User.where(email: email).first

      if user.blank? || !user.valid_password?(password)             
        render text: "Incorrect Password", :status => :bad_request
      else
        self.assign_user_session_token(user) if user.session_token.blank?
        
        render json: {:user_token => user.session_token, :user_id => user.id.to_s}
      end
    end
  end
  
  def assign_user_session_token(user)
    user.session_token = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    user.save
  end
  
end