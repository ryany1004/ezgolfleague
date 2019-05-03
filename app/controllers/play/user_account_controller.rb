class Play::UserAccountController < Play::BaseController
  layout 'golfer'

  before_action :fetch_user, only: [:edit, :update, :password, :change_password]
  before_action :fetch_league, only: [:edit]
  before_action :fetch_active_subscription, only: [:current, :edit, :update_active]
  before_action :initialize_form, only: [:edit]

  def edit; end

  def update
    if @user_account.update(user_params)
      redirect_to edit_play_user_account_path, flash:
      { success: 'Your profile was successfully updated.' }
    else
      initialize_form

      render :edit
    end
  end

  def password; end

  def change_password
    if @user_account.update(user_params)
      sign_in(@user_account, bypass: true)

      redirect_to edit_play_user_account_path, flash:
      { success: 'Your password was successfully updated.' }
    else
      redirect_to edit_play_user_account_path, flash:
      { error: 'Your passwords do not match.' }
    end
  end

  def update_active
    if @active_subscription.blank?
      active_before_update = 0
    else
      active_before_update = @active_subscription.golfer_count
    end

    active_status = params[:is_active]

    if active_status.present?
      Rails.logger.info { "Activating #{active_status.keys.count} members." }

      @league.league_memberships.each do |m|
        m.state = MembershipStates::ADDED

        if active_status.key? m.id
          membership.state = MembershipStates::ACTIVE_FOR_BILLING

          Rails.logger.info { "Updating Member to Active: #{m.user.complete_name} #{m.state}" }
        end

        m.save
      end
    end

    active_after_update = @league.league_memberships.reload.active.count
    active_delta = active_after_update - active_before_update

    if active_delta.positive?
      per_golfer_cost = SubscriptionCredit.cost_per_golfer(league: @league)
      payment_amount = per_golfer_cost * active_delta

      charge = Stripe::CardTerminal.charge_customer(@league, payment_amount: payment_amount, description: "Add active golfers for #{current_user.email} for league #{@league.name}.")

      if charge.present?
        updated_golfers = active_before_update + active_delta

        SubscriptionCredit.create(league_season: @league.active_season, amount: payment_amount, golfer_count: updated_golfers, transaction_id: charge.id)

        redirect_to current_league_subscription_credits_path(@league, details_amount: payment_amount, details_golfers: updated_golfers, details_id: charge.id), flash:
        { success: 'Your payment was recorded. Thanks!' }
      else
        redirect_to current_league_subscription_credits_path(@league), flash:
        { error: 'There was an error processing your payment.' }
      end
    else
      Rails.logger.info { "Active Delta #{active_delta}. Active After Update: #{active_after_update}" }

      redirect_to current_league_subscription_credits_path(@league), flash:
      { success: 'The memberships were successfully updated. Your account was not charged.' }
    end
  end

  def update_credit_card
    token = params[:stripeToken]

    if token.blank?
      redirect_to current_league_subscription_credits_path(@league), flash:
      { error: 'There was a problem updating your credit card. Please check your details and try again.' }
    else
      updated_successfully = Stripe::CardTerminal.create_or_update_stripe_customer(@league, user: current_user, token: token)

      if updated_successfully
        redirect_to current_league_subscription_credits_path(@league)
      else
        redirect_to current_league_subscription_credits_path(@league), flash:
        { error: 'We were unable to update your details with the credit system. Please check your details and try again.' }
      end
    end
  end

  def charge_credits
    number_of_golfers = params[:active_golfers].to_i

    payment_amount = Stripe::CardTerminal.payment_amount(number_of_golfers, league: @league)

    if number_of_golfers.zero?
      redirect_to current_league_subscription_credits_path(@league), flash:
      { error: 'We were unable to find your customer information. Please contact customer support.' }
    else
      charge = charge_customer(@league, payment_amount, "Charge for tournament credits for #{current_user.email} for league #{@league.name}.")

      if charge.present?
        SubscriptionCredit.create(league_season: @league.active_season, amount: payment_amount, golfer_count: number_of_golfers, transaction_id: charge.id)

        redirect_to current_league_subscription_credits_path(@league, details_amount: payment_amount, details_golfers: number_of_golfers, details_id: charge.id), flash:
        { success: 'Your payment was recorded. Thanks!' }
      else
        redirect_to current_league_subscription_credits_path(@league), flash:
        { error: 'There was an error processing your payment. Please verify you have a valid credit card on file. You can change your card below.' }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit! # TODO: Update
  end

  def fetch_user
    @user_account = current_user
  end

  def fetch_league
    @league = league_from_user_for_league_id(params[:league_id])
    @league = current_user.leagues_admin.first unless @league&.user_is_admin(current_user)
  end

  def fetch_active_subscription
    @golfer_count = 0
    @past_subscriptions = []

    season = @league.active_season

    if season.present?
      active_subscriptions = @league.active_season.subscription_credits.order(created_at: :desc)
      @active_subscription = active_subscriptions.try(:first)

      @golfer_count = @active_subscription.golfer_count if @active_subscription.present?

      @past_subscriptions = @league.active_season.subscription_credits
    end
  end

  def initialize_form
    @us_states = GEO_STATES
    @countries = COUNTRIES
  end
end
