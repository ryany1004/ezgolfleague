class Api::V1::PaymentsController < Api::V1::ApiBaseController
  before_action :protect_with_token

  respond_to :json

  def create
    payment_details = ActiveSupport::JSON.decode(request.body.read)

    stripe_token = payment_details["stripeToken"]
    payment_amount = payment_details["totalPaymentAmount"].to_f
    tournament_id = payment_details["tournamentID"]
    contest_ids = payment_details["contestIDs"] #TODO: Update

    tournament = Tournament.where(id: tournament_id).first

    unless stripe_token.blank? or payment_amount.blank? or tournament.blank? or @current_user.blank?
      begin
        Stripe.api_key = tournament.league.stripe_secret_key

        #add in the Stripe fees
        credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(payment_amount)
        payment_amount += credit_card_fees

        charge = Stripe::Charge.create(
          :amount => (payment_amount * 100).to_i, # amount in cents
          :currency => "usd",
          :source => stripe_token,
          :description => "#{@current_user.complete_name} Tournament: #{tournament.name}"
        )

        logger.info { "Charged #{@current_user.complete_name} Card w/ Stripe for #{payment_amount}" }

        self.create_payment(tournament.dues_for_user(@current_user, true), tournament.name, charge.id, tournament, nil)

        contest_ids.each do |contest_id|
          contest = Contest.where(id: contest_id.to_i).first

          unless contest.blank?
            self.create_payment(contest.dues_for_user(@current_user, true), contest.name, charge.id, nil, contest)

            contest.add_user(@current_user)
          end
        end

        TournamentMailer.tournament_payment_receipt(@current_user, tournament, payment_amount).deliver_later

        render json: { success: true }
      rescue Stripe::CardError => e
        render json: {"success" => false}, status: :bad_request
      end
    else
      render json: {"success" => false}, status: :bad_request
    end
  end

  def create_payment(amount, charge_description, charge_identifier, tournament, contest)
    p = Payment.new(payment_amount: amount, user: @current_user, payment_type: charge_description, payment_source: PAYMENT_METHOD_CREDIT_CARD)
    p.transaction_id = charge_identifier
    p.tournament = tournament unless tournament.blank?
    p.contest = contest unless contest.blank?
    p.save
  end

end
