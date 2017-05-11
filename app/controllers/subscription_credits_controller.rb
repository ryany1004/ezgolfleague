class SubscriptionCreditsController < BaseController
  before_action :fetch_league

  def current
    active_subscriptions = @league.subscription_credits.where("tournaments_remaining > 0").order("created_at DESC")

    @tournament_credits_remaining = 0
    @active_subscription = active_subscriptions.try(:first)

    active_subscriptions.each do |s|
      @tournament_credits_remaining += s.tournaments_remaining
    end

    @past_subscriptions = @league.subscription_credits
  end

  def update_credit_card
    Stripe.api_key = STRIPE_SECRET_KEY

    token = params[:stripeToken]

    if @league.stripe_token.blank?
      stripe_customer = Stripe::Customer.create(
        :description => "#{current_user.email} for league #{@league.name}",
        :source => token
      )

      @league.stripe_token = stripe_customer.id
      @league.save
    else
      stripe_customer = Stripe::Customer.retrieve(@league.stripe_token)

      stripe_customer.sources.create({:source => token})
    end

    stripe_card = stripe_customer.sources.data.first
    @league.cc_last_four = stripe_card.last4
    @league.cc_expire_month = stripe_card.exp_month
    @league.cc_expire_year = stripe_card.exp_year
    @league.save

    redirect_to current_league_subscription_credits_path(@league)
  end

  private

  def fetch_league
    @league = League.find(params[:league_id])
  end

end
