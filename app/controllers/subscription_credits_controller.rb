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

  #TODO: active golfer modal javascript calculator

  def update_active
    @league.league_memberships.each do |m|
      m.state = MembershipStates::ADDED
      m.save
    end

    active_status = params[:is_active]
    active_status.keys.each do |membership_id|
      membership = @league.league_memberships.where(id: membership_id).first

      unless membership.blank?
        membership.state = MembershipStates::ACTIVE_FOR_BILLING
        membership.save
      end
    end

    redirect_to current_league_subscription_credits_path(@league), :flash => { :success => "The memberships were successfully updated." }
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

  def charge_credits
    number_of_tournaments = params[:tournaments_per_season].to_i
    number_of_golfers = params[:active_golfers].to_i

    if number_of_tournaments > 15
      payment_amount = number_of_golfers * 10
    else
      payment_amount = number_of_golfers * 5
    end

    stripe_customer = Stripe::Customer.retrieve(@league.stripe_token)

    begin
      charge = Stripe::Charge.create(
        :amount => payment_amount * 100,
        :currency => "usd",
        :customer => stripe_customer,
        :description => "Charge for tournament credits for #{current_user.email} for league #{@league.name}."
      )

      SubscriptionCredit.create(league: @league, amount: payment_amount, golfer_count: number_of_golfers, tournament_count: number_of_tournaments, tournaments_remaining: number_of_tournaments, transaction_id: charge.id)

      redirect_to current_league_subscription_credits_path(@league), :flash => { :success => "Your payment was recorded. Thanks!" }
    rescue Stripe::CardError => e
      redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "There was an error processing your payment." }
    end
  end

  private

  def fetch_league
    @league = League.find(params[:league_id])
  end

end
