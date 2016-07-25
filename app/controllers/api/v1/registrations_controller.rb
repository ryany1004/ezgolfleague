class Api::V1::RegistrationsController < Api::V1::ApiBaseController
  before_filter :protect_with_token, only: [:notify_interest, :pay_dues]

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

  def search_leagues
    search_term = "%#{params[:q].downcase}%"

    @leagues = League.where(show_in_search: true).where("lower(name) LIKE ? OR lower(location) LIKE ?", search_term, search_term)

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
    payment_amount = payment_details["totalPaymentAmount"].to_f
    league_id = payment_details["leagueID"]

    league = League.where(id: league_id).first
    league_season = league.active_season

    unless stripe_token.blank? or payment_amount.blank? or league.blank? or league_season.blank? or @current_user.blank?
      begin
        Stripe.api_key = league.stripe_secret_key

        #add in the Stripe fees
        credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(payment_amount)
        payment_amount += credit_card_fees

        charge = Stripe::Charge.create(
          :amount => (payment_amount * 100).to_i, # amount in cents
          :currency => "usd",
          :source => stripe_token,
          :description => "#{@current_user.complete_name} League Dues: #{league.name}"
        )

        logger.info { "Charged #{@current_user.complete_name} Card w/ Stripe for #{payment_amount}" }

        self.create_payment(payment_amount, league.name, charge.id, league_season)

        LeagueMailer.league_dues_payment_confirmation(@current_user, league_season).deliver_later

        render json: {"success" => true}
      rescue Stripe::CardError => e
        render json: {"success" => false}, :status => :bad_request
      end
    else
      render json: {"success" => false}, :status => :bad_request
    end
  end

  def create_payment(amount, charge_description, charge_identifier, league_season)
    p = Payment.new(payment_amount: amount, user: @current_user, payment_type: charge_description, payment_source: PAYMENT_METHOD_CREDIT_CARD)
    p.transaction_id = charge_identifier
    p.league_season = league_season unless league_season.blank?
    p.save
  end

end
