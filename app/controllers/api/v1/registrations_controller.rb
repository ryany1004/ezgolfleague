class Api::V1::RegistrationsController < Api::V1::ApiBaseController
  before_action :protect_with_token, only: [:notify_interest, :pay_dues, :create_league]

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

      self.assign_user_session_token(user) if user.session_token.blank?

      render json: {:user_token => user.session_token, :user_id => user.id.to_s}
    else
      create_errors = { errors: user.errors }

      respond_with(create_errors) do |format|
        format.json { render :json => create_errors }
      end
    end
  end

  def create_league
    details = ActiveSupport::JSON.decode(request.body.read)

    name = details["name"]
    location = details["location"]
    appear_in_search = details["appearInSearch"]

    league = League.create(name: name, location: location, show_in_search: appear_in_search, contact_name: @current_user.complete_name, contact_email: @current_user.email, contact_phone: @current_user.phone_number, league_description: "")
    league.exempt_from_subscription = true #TODO: REMOVE

    if league.save
      LeagueMembership.create(user: @current_user, league: league, is_admin: true)

      render json: league
    else
      create_errors = { errors: league.errors }

      respond_with(create_errors) do |format|
        format.json { render :json => create_errors }
      end
    end
  end

  def search_leagues
    @leagues = []

    search_term = "%#{params[:q].strip}%"

    search_term.split(" ").each do |s|
      s = s.downcase

      @leagues += League.where(show_in_search: true).where("lower(name) LIKE ? OR lower(location) LIKE ?", s, s)
    end

    @leagues = @leagues.uniq

    respond_with(@leagues) do |format|
      format.json { render :json => @leagues }
    end
  end

  def league_tournament_info
      @league = League.find(params[:league_id])

      upcoming_tournaments = Tournament.all_upcoming([@league], nil)

      respond_with(upcoming_tournaments) do |format|
        format.json { render :json => upcoming_tournaments }
      end
  end

  def notify_interest
    league = League.find(params[:league_id])

    LeagueMailer.league_interest(@current_user, league).deliver_later unless league.blank?

    render json: {"success" => true}
  end

  def pay_dues
    payment_details = ActiveSupport::JSON.decode(request.body.read)

    stripe_token = payment_details["stripeToken"]
    league_id = payment_details["leagueID"]
    league = League.where(id: league_id).first

    begin
      Payments::LeagueJoinService.charge_and_join(@current_user, league, stripe_token)

      render json: {"success" => true}
    rescue Stripe::CardError => e
      render json: {"success" => false}, :status => :bad_request
    end
  end
end
