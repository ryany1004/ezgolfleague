module Payments
  class LeagueJoinService
    def self.charge_and_join(user, league, stripe_token)
      league_season = league.league_seasons.last
      api_key = league.stripe_secret_key

      amount_to_charge = LeagueJoinService.payment_amount(league)
      charge_description = "#{user.complete_name} League Dues"

      Rails.logger.info { "Sending Stripe Charge: #{amount_to_charge} for #{charge_description}" }

      Stripe.api_key = api_key

      charge = Stripe::Charge.create(
        :amount => (amount_to_charge * 100).to_i, # amount in cents
        :currency => "usd",
        :source => stripe_token,
        :description => charge_description
      )

      LeagueJoinService.create_payment(amount_to_charge * - 1.0, user, league.name, charge.id, league_season) #debit
      LeagueJoinService.create_payment(amount_to_charge, user, league.name, charge.id, league_season) #credit

      user.leagues << league

      if league.dues_payment_receipt_email_addresses.present?
        email_addresses = nil
        email_addresses = league.dues_payment_receipt_email_addresses.split(",")

        RecordEventJob.perform_later(email_addresses, "A user paid league dues", { league_name: league_season.league.name, season_name: league_season.complete_name, dues_paid: league_season.league.dues_for_user(user, true), user: { complete_name: user.complete_name, email: user.email, phone_number: user.phone_number} }) unless email_addresses.blank?
      end
    end

    def self.payment_amount(league)
      league.dues_amount + Stripe::StripeFees.fees_for_transaction_amount(league.dues_amount)
    end

    def self.create_payment(amount, user, charge_description, charge_identifier, league_season)
      p = Payment.new(payment_amount: amount, user: user, payment_type: charge_description, payment_source: PAYMENT_METHOD_CREDIT_CARD)
      p.transaction_id = charge_identifier
      p.league_season = league_season
      p.save
    end
  end
end
