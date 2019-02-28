class Api::V1::PaymentsController < Api::V1::ApiBaseController
  before_action :protect_with_token

  respond_to :json

  def create
    payment_details = ActiveSupport::JSON.decode(request.body.read)

    stripe_token = payment_details["stripeToken"]
    payment_amount = payment_details["totalPaymentAmount"].to_f
    tournament_id = payment_details["tournamentID"]
    optional_scoring_rule_ids = payment_details["contestIDs"] #TODO: Update

    tournament = Tournament.where(id: tournament_id).first

    unless stripe_token.blank? or payment_amount.blank? or tournament.blank? or @current_user.blank?
      begin
        Stripe.api_key = tournament.league.stripe_secret_key

        #add in the Stripe fees
        credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(payment_amount)
        payment_amount += credit_card_fees

        charge = Stripe::Charge.create(
          amount: (payment_amount * 100).to_i, # amount in cents
          currency: "usd",
          source: stripe_token,
          description: "#{@current_user.complete_name} Tournament: #{tournament.name}"
        )

        logger.info { "Charged #{@current_user.complete_name} Card w/ Stripe for #{payment_amount}" }

        amount = tournament.dues_for_user(@current_user, true)
        self.create_payment(amount: amount, charge_description: tournament.name, charge_identifier: charge.id, scoring_rule: tournament.mandatory_scoring_rules.first)

        optional_scoring_rule_ids.each do |rule_id|
          scoring_rule = ScoringRule.where(id: rule_id.to_i).first

          if scoring_rule.present?
            amount = scoring_rule.dues_for_user(user: @current_user, include_credit_card_fees: true)
            self.create_payment(amount: amount, charge_description: scoring_rule.name, charge_identifier: charge.id, scoring_rule: scoring_rule)

            scoring_rule.users << @current_user
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

  def create_payment(amount:, charge_description:, charge_identifier:, scoring_rule:)
    Payment.create(
      scoring_rule: scoring_rule,
      payment_amount: amount,
      user: @current_user,
      payment_type: charge_description,
      payment_source: PAYMENT_METHOD_CREDIT_CARD,
      transaction_id: charge_identifier,
    )
  end

end
