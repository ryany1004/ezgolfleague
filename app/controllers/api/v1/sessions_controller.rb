class Api::V1::SessionsController < Api::V1::ApiBaseController
  before_filter :protect_with_token, only: [:register_device, :upload_avatar_image]

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

  def register_device
    existing_device = @current_user.mobile_devices.where(device_identifier: params[:device_identifier]).first

    if existing_device.blank?
      MobileDevice.create(user: @current_user, device_identifier: params[:device_identifier], device_type: params[:device_type], environment_name: params[:environment_name])
    end

    render text: "Success"
  end

  def upload_avatar_image
    uploaded_image = request.body.read

    if uploaded_image.blank?
      render text: "Bad Image", :status => :bad_request
    else
      temp_file_path = "#{Rails.root}/tmp/#{SecureRandom.uuid}_golfer_avatar.jpg"

      File.delete(temp_file_path) if File.exist?(temp_file_path)
      File.open(temp_file_path, 'w') {|f| f.write(uploaded_image.force_encoding('UTF-8'))}

      @current_user.avatar = File.open(temp_file_path)
      @current_user.save

      respond_with(@current_user) do |format|
        format.json { render :json => @current_user.to_json }
      end
    end
  end

  def assign_user_session_token(user)
    user.session_token = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    user.save
  end

end
