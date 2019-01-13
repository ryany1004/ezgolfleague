class Play::PaymentsController < Play::BaseController
  layout "golfer"

  def index
  end

  def new
    if params[:payment_type] == 'league_dues'
      @league = self.view_league_from_user_for_league_id(params[:league_id])

      @payment_instructions = "Thanks for paying your league dues via EZ Golf League. Please enter your information below."
      @payment_amount = @league.dues_for_user(current_user)
      @cost_breakdown_lines = @league.cost_breakdown_for_user(current_user)
    elsif params[:payment_type] == 'contest_dues'
      @contest = Contest.find(params[:contest_id])

      @payment_instructions = "Thanks for paying your contest dues via EZ Golf League. Please enter your information below."
      @payment_amount = @contest.dues_for_user(current_user, true)
      @cost_breakdown_lines = @contest.cost_breakdown_for_user(current_user)
    elsif params[:payment_type] == 'tournament_dues'
      @tournament = self.view_tournament_from_user_for_tournament_id(params[:tournament_id])

      @payment_instructions = "Thanks for paying your tournament dues via EZ Golf League. Please enter your information below."
      @payment_amount = @tournament.dues_for_user(current_user, false)
      @cost_breakdown_lines = @tournament.cost_breakdown_for_user(current_user, true, true)

      #add in any contest dues required
      @tournament.paid_contests.each do |c|
        if c.users.include? current_user
          @payment_amount += c.dues_for_user(current_user, false)
        end
      end

      @payment_amount += Stripe::StripeFees.fees_for_transaction_amount(@payment_amount)
    else
      @payment_instructions = "Thanks for paying via EZ Golf League. Please enter your information below."
    end
  end

  #TODO: This is a mess and should be re-factored. One single call w/ the API as well.

  def create
    if params[:tournament_id] != nil
      tournament = self.view_tournament_from_user_for_tournament_id(params[:tournament_id])

      amount = tournament.total_for_user_with_contest_fees(current_user, true)
      api_key = tournament.league.stripe_secret_key
      charge_description = "#{current_user.complete_name} Tournament: #{tournament.name}"
    elsif params[:contest_id] != nil
      contest = Contest.find(params[:contest_id])

      amount = contest.dues_for_user(current_user, true)
      api_key = contest.tournament_day.tournament.league.stripe_secret_key
      charge_description = "#{current_user.complete_name} Contest Dues"
    elsif params[:league_id] != nil
      league = self.view_league_from_user_for_league_id(params[:league_id])
      league_season = league.league_seasons.last #NOTE: this is always going to be attached to the last one

      amount = league.dues_for_user(current_user)
      api_key = league.stripe_secret_key
      charge_description = "#{current_user.complete_name} League Dues"
    end

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

      #create payment records
      unless league_season.blank?
        league.set_user_as_active(current_user) #make this golfer active

        Payment.create(payment_amount: (amount * -1.0), user: current_user, payment_type: charge_description, league_season: league_season)

        if league.dues_payment_receipt_email_addresses.present?
          email_addresses = nil
          email_addresses = league.dues_payment_receipt_email_addresses.split(",")

          RecordEventJob.perform_later(email_addresses, "A user paid league dues", { league_name: league_season.league.name, season_name: league_season.complete_name, dues_paid: league_season.league.dues_for_user(user, true), user: { complete_name: current_user.complete_name, email: current_user.email, phone_number: current_user.phone_number} }) unless email_addresses.blank?
        end

        self.create_payment(amount, charge_description, charge.id, nil, nil, league_season) #league dues
      else
        unless tournament.blank?
          self.create_payment(tournament.dues_for_user(current_user, false), charge_description, charge.id, tournament, nil, nil) #tournaments and any contests

          tournament.paid_contests.each do |c|
            if c.users.include? current_user
              self.create_payment(c.dues_for_user(current_user, false), charge_description, charge.id, nil, c, nil)
            end
          end
        end

        unless contest.blank?
          self.create_payment(contest.dues_for_user(current_user, false), charge_description, charge.id, nil, contest, nil) #just a contest
        end
      end

      #confirm player
      tournament.confirm_player(current_user) unless tournament.blank?

      #actually add to the contests
      unless contest.blank?
        contest.add_user(current_user)
      end

      TournamentMailer.tournament_payment_receipt(current_user, tournament, amount.to_f).deliver_later unless tournament.blank?

      redirect_to thank_you_play_payments_path
    rescue Stripe::CardError => e
      redirect_to error_play_payments_path
    end
  end

  def create_payment(amount, charge_description, charge_identifier, tournament, contest, league_season)
    p = Payment.new(payment_amount: amount, user: current_user, payment_type: charge_description, payment_source: PAYMENT_METHOD_CREDIT_CARD)
    p.transaction_id = charge_identifier
    p.tournament = tournament unless tournament.blank?
    p.league_season = league_season unless league_season.blank?
    p.contest = contest unless contest.blank?
    p.save
  end

  def thank_you
    @payment = Payment.where(user: current_user).last
  end

  def error
  end

end
