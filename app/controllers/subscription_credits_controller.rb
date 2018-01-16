class SubscriptionCreditsController < BaseController
  before_action :fetch_league
  before_action :fetch_active_subscription, only: [:current, :update_active]

  def current
  end

  def information
    render :layout => 'golfer'
  end

  def new
    unless @league.stripe_token.blank?
      redirect_to current_league_subscription_credits_path(@league)
    else
      render :layout => 'golfer'
    end
  end

  def create
    number_of_golfers = params[:active_golfers].to_i
    number_of_tournaments = params[:tournaments_per_season].to_i
    payment_amount = calc_payment_amount(number_of_tournaments, number_of_golfers)
    token = params[:stripeToken]

    create_or_update_stripe_customer(@league, token)

    user = @league.league_memberships.first.user

    charge = charge_customer(@league, payment_amount, "Charge for tournament credits for #{user.email} for league #{@league.name}.")

    unless charge.blank?
      SubscriptionCredit.create(league: @league, amount: payment_amount, golfer_count: number_of_golfers, tournament_count: number_of_tournaments, tournaments_remaining: number_of_tournaments, transaction_id: charge.id)

      redirect_to setup_completed_play_registrations_path(details_amount: payment_amount, details_golfers: number_of_golfers, details_id: charge.id)
    else
      redirect_to information_league_subscription_credits_path(@league), :flash => { :error => "There was an error processing your payment." }
    end
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
      #per_golfer_cost = SubscriptionCredit.cost_for_tournament_count(@active_subscription.tournament_count) #TODO: REMOVE?
      per_golfer_cost = 5
      payment_amount = per_golfer_cost * active_delta

      charge = charge_customer(@league, payment_amount, "Add active golfers for #{current_user.email} for league #{@league.name}.")

      unless charge.blank?
        updated_golfers = active_before_update + active_delta

        SubscriptionCredit.create(league: @league, amount: payment_amount, golfer_count: updated_golfers, tournament_count: @active_subscription.tournament_count, tournaments_remaining: @tournament_credits_remaining, transaction_id: charge.id)

        @active_subscriptions.each do |s|
          s.tournaments_remaining = 0
          s.save
        end

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

    create_or_update_stripe_customer(@league, token)

    redirect_to current_league_subscription_credits_path(@league)
  end

  def charge_credits
    number_of_tournaments = params[:tournaments_per_season].to_i
    number_of_golfers = params[:active_golfers].to_i
    payment_amount = calc_payment_amount(number_of_tournaments, number_of_golfers)

    if number_of_golfers == 0 || number_of_tournaments == 0
      redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "We were unable to find your customer information. Please contact customer support." }
    else
      charge = charge_customer(@league, payment_amount, "Charge for tournament credits for #{current_user.email} for league #{@league.name}.")

      unless charge.blank?
        SubscriptionCredit.create(league: @league, amount: payment_amount, golfer_count: number_of_golfers, tournament_count: number_of_tournaments, tournaments_remaining: number_of_tournaments, transaction_id: charge.id)

        redirect_to current_league_subscription_credits_path(@league, details_amount: payment_amount, details_golfers: number_of_golfers, details_id: charge.id), :flash => { :success => "Your payment was recorded. Thanks!" }
      else
        redirect_to current_league_subscription_credits_path(@league), :flash => { :error => "There was an error processing your payment." }
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
    @active_subscriptions = @league.subscription_credits.where("tournaments_remaining > 0").order("created_at DESC")
    @active_subscription = @active_subscriptions.try(:first)

    unless @active_subscription.blank?
      @tournament_count = @active_subscription.tournament_count
      @golfer_count = @active_subscription.golfer_count
    else
      @tournament_count = 12
      @golfer_count = 15
    end

    @tournament_credits_remaining = 0
    @active_subscriptions.each do |s|
      @tournament_credits_remaining += s.tournaments_remaining
    end

    @past_subscriptions = @league.subscription_credits
  end

  def calc_payment_amount(number_of_tournaments, number_of_golfers)
    number_of_golfers * SubscriptionCredit.cost_for_tournament_count(number_of_tournaments)
  end

  def create_or_update_stripe_customer(league, token)
    Stripe.api_key = STRIPE_SECRET_KEY

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

    stripe_card = stripe_customer.sources.data.first
    league.cc_last_four = stripe_card.last4
    league.cc_expire_month = stripe_card.exp_month
    league.cc_expire_year = stripe_card.exp_year
    league.save
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
