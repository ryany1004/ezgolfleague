class Api::V1::RegistrationsController < Api::V1::ApiBaseController
  respond_to :json

  def create
    details = ActiveSupport::JSON.decode(request.body.read)

    email = details["emailAddress"]
    first_name = details["firstName"]
    last_name = details["lastName"]
    password = details["password"]
    phone_number = details["phoneNumber"]
    ghin_number = details["ghinNumber"]

    user = User.create(email: email, first_name: first_name, last_name: last_name, password: password, password_confirmation: password, phone_number: phone_number, ghin_number: ghin_number)

    if user.save
      Delayed::Job.enqueue GhinUpdateJob.new([user]) unless user.ghin_number.blank?

      respond_with(user) do |format|
        format.json { render :json => user }
      end
    else
      create_errors = { errors: user.errors }

      respond_with(create_errors) do |format|
        format.json { render :json => create_errors }
      end
    end
  end

  def search_leagues
    #search for leagues
  end

  def league_info

  end

  def notify_interest
    #send email to league admin with info on wanting to be registered
  end

  def pay_dues
    #actually pay the dues
    #send email receipt
  end

end
