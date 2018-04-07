class SubscriptionCreditsController < BaseController
  before_action :fetch_league
  before_action :fetch_active_subscription, only: [:current, :update_active]

  def current
  end

  def information
    render :layout => 'golfer'
  end

  def update_active
    if @active_subscription.blank?
      active_before_update = 0
    else
      active_before_update = @active_subscription.golfer_count
    end

    @league.league_memberships.each do |m|
      m.state = MembershipStates::ADDED
      m.save
    end

    active_status = params[:is_active]
    unless active_status.blank?
      active_status.keys.each do |membership_id|
      membership = @league.league_memberships.where(id: membership_id).first

      unless membership.blank?
         membership.state = MembershipStates::ACTIVE_FOR_BILLING
         membership.save
       end
      end
    end

    active_after_update = @league.league_memberships.active.count

    active_delta = active_after_update - active_before_update

    if active_delta > 0
      per_golfer_cost = SubscriptionCredit.cost_per_golfer
      payment_amount = per_golfer_cost * active_delta

      charge = charge_customer(@league, payment_amount, "Add active golfers for #{current_user.email} for league #{@league.name}.")

      unless charge.blank?
        updated_golfers = active_before_update + active_delta

        SubscriptionCredit.create(league_season: @league.active_season, amount: payment_amount, golfer_count: updated_golfers, transaction_id: charge.id)

        redirect_to current_league_subscription_credits_path(@league, details_amount: payment_amount, details_golfers: updated_golfers, details_id: charge.id), :flash => { :success => "Your payment was recorded. Thanks!" }
      else
        redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "There was an error processing your payment." }
      end
    else
      redirect_to current_league_subscription_credits_path(@league), :flash => { :success => "The memberships were successfully updated." }
    end
  end

  def update_credit_card
    token = params[:stripeToken]

    if token.blank?
      redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "There was a problem updating your credit card. Please check your details and try again." }
    else
      updated_successfully = create_or_update_stripe_customer(@league, token)

      if updated_successfully
        redirect_to current_league_subscription_credits_path(@league)
      else
        redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "We were unable to update your details with the credit system. Please check your details and try again." }
      end
    end
  end

  def charge_credits
    number_of_golfers = params[:active_golfers].to_i

    payment_amount = calc_payment_amount(number_of_golfers)

    if number_of_golfers == 0
      redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "We were unable to find your customer information. Please contact customer support." }
    else
      charge = charge_customer(@league, payment_amount, "Charge for tournament credits for #{current_user.email} for league #{@league.name}.")

      unless charge.blank?
        SubscriptionCredit.create(league_season: @league.active_season, amount: payment_amount, golfer_count: number_of_golfers, transaction_id: charge.id)

        redirect_to current_league_subscription_credits_path(@league, details_amount: payment_amount, details_golfers: number_of_golfers, details_id: charge.id), :flash => { :success => "Your payment was recorded. Thanks!" }
      else
        redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "There was an error processing your payment. Please verify you have a valid credit card on file. You can change your card below." }
      end
    end
  end

  private

  def fetch_league
    @league = League.find(params[:league_id])

    if !@league.user_is_admin(current_user)
      @league = current_user.leagues_admin.first
    end
  end

  def fetch_active_subscription
    @golfer_count = 0
    @past_subscriptions = []

    season = @league.active_season
    unless season.blank?
      active_subscriptions = @league.active_season.subscription_credits.order("created_at DESC")
      @active_subscription = active_subscriptions.try(:first)

      @golfer_count = @active_subscription.golfer_count unless @active_subscription.blank?

      @past_subscriptions = @league.active_season.subscription_credits
    end
  end

  def calc_payment_amount(number_of_golfers)
    number_of_golfers * SubscriptionCredit.cost_per_golfer
  end

  def create_or_update_stripe_customer(league, token)
    Stripe.api_key = STRIPE_SECRET_KEY

    update_successful = false

    if league.stripe_token.blank?
      stripe_customer = Stripe::Customer.create(
        :description => "#{current_user.email} for league #{league.name}",
        :source => token
      )

      league.stripe_token = stripe_customer.id
      league.save
    else
      stripe_customer = Stripe::Customer.retrieve(league.stripe_token)

      stripe_customer.sources.create({:source => token})
    end

    unless stripe_customer.sources.data.blank?
      stripe_card = stripe_customer.sources.data.first
      league.cc_last_four = stripe_card.last4
      league.cc_expire_month = stripe_card.exp_month
      league.cc_expire_year = stripe_card.exp_year
      league.save

      update_successful = true
    end

    update_successful
  end

  def charge_customer(league, payment_amount, description)
    Stripe.api_key = STRIPE_SECRET_KEY

    stripe_customer = Stripe::Customer.retrieve(@league.stripe_token)

    unless stripe_customer.blank?
      begin
        charge = Stripe::Charge.create(
          :amount => payment_amount * 100,
          :currency => "usd",
          :customer => stripe_customer,
          :description => description
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
