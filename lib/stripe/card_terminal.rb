module Stripe
  class CardTerminal

	  def self.payment_amount(number_of_golfers, league:)
	    number_of_golfers * SubscriptionCredit.cost_per_golfer(league: league)
	  end

	  def self.create_or_update_stripe_customer(league, user:, token:)
	    Stripe.api_key = STRIPE_SECRET_KEY

	    update_successful = false

			begin
				if league.stripe_token.present?
					stripe_customer = Stripe::Customer.retrieve(league.stripe_token)
	
					card = stripe_customer.sources.create({ source: token })
					card.save
	
					stripe_customer.default_source = card.id
					stripe_customer.save
				else
					stripe_customer = Stripe::Customer.create(
						description: "#{user.email} for league #{league.name}",
						source: token
					)
	
					league.stripe_token = stripe_customer.id
					league.save
				end
	
				if stripe_customer.sources.data.present?
					stripe_card = stripe_customer.sources.data.first
	
					league.cc_last_four = stripe_card.last4
					league.cc_expire_month = stripe_card.exp_month
					league.cc_expire_year = stripe_card.exp_year
					league.save
	
					update_successful = true
				end
	
				return update_successful
			rescue Stripe::CardError => e
				return false
			end
	  end

	  def self.charge_customer(league, payment_amount:, description:)
	    Stripe.api_key = STRIPE_SECRET_KEY

	    stripe_customer = Stripe::Customer.retrieve(league.stripe_token)

	    if stripe_customer.present?
	      begin
	        charge = Stripe::Charge.create(
	          amount: payment_amount.to_i * 100,
	          currency: "usd",
	          customer: stripe_customer,
	          description: description
	        )

	        charge
	      rescue Stripe::CardError => e
	        nil
	      end
	    else
	      nil
	    end
	  end

  end
end
