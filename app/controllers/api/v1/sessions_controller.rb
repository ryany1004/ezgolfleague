class Api::V1::SessionsController < Api::V1::ApiBaseController
  before_action :protect_with_token, only: [:register_device, :upload_avatar_image]

  respond_to :json

  def create
    email = request.headers["ezgl-email"].strip.downcase
    password = request.headers["ezgl-password"]

    if email.blank? or password.blank?
      render json: { message: "Error"}, status: :precondition_failed, content_type: 'application/json'
    else
      user = User.where(email: email).first

      if user.blank? || !user.valid_password?(password)
        render json: { message: "#{email}"}, status: :unauthorized, content_type: 'application/json'
      else
        self.assign_user_session_token(user) if user.session_token.blank?

        render json: { user_token: user.session_token, user_id: user.id.to_s}, content_type: 'application/json'
      end
    end
  end

  def register_device
    existing_device = @current_user.mobile_devices.where(device_identifier: params[:device_identifier]).first

    if existing_device.blank?
      MobileDevice.create(user: @current_user, device_identifier: params[:device_identifier], device_type: params[:device_type], environment_name: params[:environment_name])
    end

    respond_to do |format|
      format.json { render json: { message: "Success"}, status: :ok, content_type: 'application/json' }
    end
  end

  def upload_avatar_image
    uploaded_image = request.body.read

    if uploaded_image.blank?
      render plain: "Bad Image", status: :bad_request
    else
      temp_file_path = "#{Rails.root}/tmp/#{SecureRandom.uuid}_golfer_avatar.jpg"

      File.delete(temp_file_path) if File.exist?(temp_file_path)
      File.open(temp_file_path, 'w') {|f| f.write(uploaded_image.force_encoding('UTF-8'))}

      @current_user.avatar = File.open(temp_file_path)
      @current_user.save

      #NOTE: bust the cache for associated tournaments
      @current_user.tournaments.each do |t|
        t.tournament_days.each do |d|
          d.touch
        end
      end

      render plain: "Success", status: :ok
    end
  end

end
