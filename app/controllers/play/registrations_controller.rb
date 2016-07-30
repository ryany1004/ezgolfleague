class Play::RegistrationsController < BaseController
    include Devise::Controllers::Helpers

    layout "golfer"

    skip_before_action :authenticate_user!

    def new
      @user_account = User.new
    end

    def create
      @user_account = User.new(user_params)

      if @user_account.save
        Delayed::Job.enqueue GhinUpdateJob.new([@user_account]) unless @user_account.ghin_number.blank?

        session[:temporary_user_id] = @user_account.id

        redirect_to leagues_play_registrations_path, :flash => { :success => "Your account was created." }
      else
        render :new
      end
    end

    def leagues
    end

    def search_leagues
      search_term = "%#{params[:search].downcase}%"

      @leagues = League.where(show_in_search: true).where("lower(name) LIKE ? OR lower(location) LIKE ?", search_term, search_term)
    end

    def league_info
      @league = League.find(params[:league_id])
      @upcoming_tournaments = Tournament.all_upcoming([@league], nil)
    end

    def join_league
      @user_account = temporary_user
      @league = League.find(params[:league_id])

      @cost_breakdown_lines = [
        {:name => "#{@league.name} League Fees", :price => @league.dues_amount},
        {:name => "Credit Card Fees", :price => Stripe::StripeFees.fees_for_transaction_amount(@league.dues_amount)}
      ]

      @payment_amount = payment_amount(@league)
    end

    def request_information
      @user_account = temporary_user

      league = League.find(params[:league_id])

      LeagueMailer.league_interest(@user_account, league).deliver_later unless league.blank?

      render :thanks
    end

    def submit_payment
      @current_user = temporary_user

      league = League.find(params[:league_id])
      league_season = league.league_seasons.last

      amount = payment_amount(league)
      api_key = league.stripe_secret_key
      charge_description = "#{@current_user.complete_name} League Dues"

      Payment.create(payment_amount: (amount * -1.0), user: @current_user, payment_type: charge_description, league_season: league_season)

      Stripe.api_key = api_key

      # Get the credit card details submitted by the form
      token = params[:stripeToken]

      Rails.logger.info { "Sending Stripe Charge: #{amount} for #{charge_description}" }

      #at this point the charges are already included in the above

      # Create the charge on Stripe's servers - this will charge the user's card
      begin
        charge = Stripe::Charge.create(
          :amount => (amount * 100).to_i, # amount in cents
          :currency => "usd",
          :source => token,
          :description => charge_description
        )

        self.create_payment(amount, charge_description, charge.id, league_season) #league dues

        @current_user.leagues << league

        sign_in(@current_user)

        LeagueMailer.league_dues_payment_confirmation(@current_user, league_season).deliver_later unless league.dues_payment_receipt_email_addresses.blank?

        redirect_to play_dashboard_index_path, :flash => { :success => "You have joined the league." }
      rescue Stripe::CardError => e
        redirect_to error_play_payments_path
      end
    end

    def create_payment(amount, charge_description, charge_identifier, league_season)
      p = Payment.new(payment_amount: amount, user: @current_user, payment_type: charge_description, payment_source: PAYMENT_METHOD_CREDIT_CARD)
      p.transaction_id = charge_identifier
      p.league_season = league_season
      p.save
    end

    private

    def user_params
      params.require(:user).permit!
    end

    def payment_amount(league)
      league.dues_amount + Stripe::StripeFees.fees_for_transaction_amount(league.dues_amount)
    end

    def temporary_user
      User.where(id: session[:temporary_user_id]).first
    end
end
