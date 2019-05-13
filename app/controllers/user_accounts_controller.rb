class UserAccountsController < BaseController
  before_action :fetch_user_account, only: [:edit, :update, :destroy]
  before_action :fetch_league, only: [:edit]
  before_action :fetch_active_subscription, only: [:current, :edit, :update_active]
  before_action :initialize_form, only: [:new, :edit, :edit_current]

  def index
    @page_title = 'User Accounts'

    if current_user.is_super_user?
      @user_accounts = User.order(:last_name).page params[:page]
    else
      membership_ids = current_user.leagues_admin.map(&:id)
      @user_accounts = User.joins(:league_memberships).where('league_memberships.league_id IN (?)', membership_ids).order(:last_name).page params[:page]
    end

    return if params[:search].blank?

    search_string = "%#{params[:search].downcase}%"
    @user_accounts = @user_accounts.where('lower(last_name) LIKE ? OR lower(first_name) LIKE ? OR lower(email) LIKE ?', search_string, search_string, search_string)
  end

  def new
    @user_account = User.new
  end

  def create
    @user_account = User.new(user_params)

    if @user_account.should_invite == '1'
      User.invite!(user_params, current_user)

      redirect_to user_accounts_path, flash:
      { success: 'The user was successfully invited.' }
    else
      unless current_user.is_super_user?
        @user_account.leagues << current_user.leagues_admin.first if current_user.leagues_admin.present? # add the user to at least one league
      end

      if @user_account.save
        GhinUpdateJob.perform_later([@user_account]) if @user_account.ghin_number.present?

        redirect_to user_accounts_path, flash:
        { success: 'The user was successfully created.' }
      else
        initialize_form

        render :new
      end
    end
  end

  def edit; end

  def update
    if @user_account.update(user_params)
      if @user_account.ghin_number.present?
        Rails.logger.info { "Updating GHIN for #{@user_account}" }

        GhinUpdateJob.perform_later([@user_account.id])
      else
        Rails.logger.info { "Not Updating GHIN for #{@user_account}" }
      end

      if @user_account.account_to_merge_to.present?
        destination_account = User.find(@user_account.account_to_merge_to)

        @user_account.merge_into_user(destination_account)
      end

      if @user_account == current_user
        redirect_to root_path
      else
        redirect_to user_accounts_path, flash:
        { success: 'The user was successfully updated.' }
      end
    else
      initialize_form

      render :edit
    end
  end

  def destroy
    Tournament.all_upcoming(@user_account.leagues).each do |t|
      next unless t.includes_player?(@user_account)

      t.tournament_days.each do |d|
        group = d.tournament_group_for_player(@user_account)

        d.remove_player_from_group(group, @user_account, true) if group.present?
      end
    end

    @user_account.destroy

    redirect_to user_accounts_path, flash: { success: 'The user was successfully deleted.' }
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

  def export_users
    @users = User.all

    respond_to do |format|
      format.csv { send_data @users.to_csv, filename: "all_users-#{Time.zone.today}.csv" }
    end
  end

  def impersonate
    user = User.find(params[:user_account_id])

    session[:selected_season_id] = nil

    impersonate_user(user)

    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  def edit_current
    @user_account = current_user
    @editing_current_user = true
  end

  def setup_league_admin_invite
    @user_account = User.new
    @leagues = League.all.order(:name)
  end

  def send_league_admin_invite
    if invite_user(user_params, true)
      redirect_to user_accounts_path, flash:
      { success: 'The league admin was successfully invited.' }
    else
      redirect_to user_accounts_path, flash:
      { error: 'There was an error inviting the league admin. Please check your information and try again.' }
    end
  end

  def resend_league_invite
    user = User.find(params[:user_account_id])

    user.invite!(current_user)

    redirect_to user_accounts_path, flash:
    { success: 'The golfer was successfully re-invited.' }
  end

  def setup_golfer_invite
    @user_account = User.new

    if current_user.is_super_user?
      @leagues = League.all.order(:name)
    else
      @leagues = current_user.leagues.order(:name)
    end
  end

  def send_golfer_invite
    if invite_user(user_params, false)
      redirect_to user_accounts_path, flash:
      { success: 'The golfer was successfully invited.' }
    else
      redirect_to user_accounts_path, flash:
      { error: 'There was an error inviting the golfer. Please check your information and try again.' }
    end
  end

  def invite_user(user_params, is_admin = false)
    existing_user = User.where(email: user_params[:email]).first

    if existing_user.blank?
      @user_account = User.new(user_params)
      @user_account.password = 'temporary_password1234'
      @user_account.password_confirmation = 'temporary_password1234'

      if @user_account.save
        @user_account.league_memberships.each do |m|
          m.state = MembershipStates::INVITED
          m.is_admin = is_admin
          m.save
        end

        user = User.invite!({ email: @user_account.email }, current_user) do |u|
          u.skip_invitation = true
        end

        user.deliver_invitation

        return true
      else
        @user_account.errors.each do |e|
          Rails.logger.debug { e.to_s }
        end

        return false
      end
    else
      user_params[:league_ids].each do |league_id|
        next if league_id.blank?

        league = League.find(league_id)

        existing_membership = existing_user.league_memberships.where('league_id = ?', league.id)

        LeagueMembership.create(league: league, user: existing_user, is_admin: is_admin, state: MembershipStates::ADDED) if existing_membership.blank?
      end

      return true
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

        redirect_to edit_play_user_account_path, flash:
        { success: 'Your payment was recorded. Thanks!' }
      else
        redirect_to edit_play_user_account_path, flash:
        { error: 'There was an error processing your payment.' }
      end
    else
      Rails.logger.info { "Active Delta #{active_delta}. Active After Update: #{active_after_update}" }

      redirect_to edit_play_user_account_path, flash:
      { success: 'The memberships were successfully updated. Your account was not charged.' }
    end
  end

  def update_credit_card
    token = params[:stripeToken]

    if token.blank?
      redirect_to edit_play_user_account_path, flash:
      { error: 'There was a problem updating your credit card. Please check your details and try again.' }
    else
      updated_successfully = Stripe::CardTerminal.create_or_update_stripe_customer(@league, user: current_user, token: token)

      if updated_successfully
        redirect_to edit_play_user_account_path
      else
        redirect_to edit_play_user_account_path, flash:
        { error: 'We were unable to update your details with the credit system. Please check your details and try again.' }
      end
    end
  end

  def charge_credits
    number_of_golfers = params[:active_golfers].to_i

    payment_amount = Stripe::CardTerminal.payment_amount(number_of_golfers, league: @league)

    if number_of_golfers.zero?
      redirect_to edit_play_user_account_path, flash:
      { error: 'We were unable to find your customer information. Please contact customer support.' }
    else
      charge = charge_customer(@league, payment_amount, "Charge for tournament credits for #{current_user.email} for league #{@league.name}.")

      if charge.present?
        SubscriptionCredit.create(league_season: @league.active_season, amount: payment_amount, golfer_count: number_of_golfers, transaction_id: charge.id)

        redirect_to edit_play_user_account_path, flash:
        { success: 'Your payment was recorded. Thanks!' }
      else
        redirect_to edit_play_user_account_path, flash:
        { error: 'There was an error processing your payment. Please verify you have a valid credit card on file. You can change your card below.' }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def fetch_user_account
    @user_account = User.find(params[:id])

    redirect_to root_path if !current_user.can_edit_user?(@user_account)
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

    if current_user.is_super_user?
      @leagues = League.all.order(:name)
    else
      @leagues = current_user.leagues_admin.order(:name)
    end
  end
end
