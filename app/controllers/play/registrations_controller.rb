class Play::RegistrationsController < Play::BaseController
  include Devise::Controllers::Helpers

  layout 'onboarding'

  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    @user_account = User.new

    @show_apps_in_footer = false
  end

  def create
    @user_account = User.new(user_params)
    @show_apps_in_footer = false

    if @user_account.save
      GhinUpdateJob.perform_later([@user_account.id]) if @user_account.ghin_number.present?

      sign_in(@user_account, scope: :user)

      redirect_to leagues_play_registrations_path, flash:
      { success: 'Your account was created.' }
    else
      render :new
    end
  end

  def leagues
    @show_apps_in_footer = false

    @leagues = League.where(show_in_search: true).order(:name)
  end

  def leagues_list
    @leagues = League.where(show_in_search: true).order(:name)

    if params[:search].present?
      search_string = "%#{params[:search].downcase}%"

      @leagues = @leagues.where('lower(name) LIKE ? OR lower(location) LIKE ?', search_string, search_string)
    end

    render json: @leagues.to_json
  end

  def join_league
    @league = League.find(params[:league_id])

    if @league.encrypted_stripe_production_publishable_key.blank? || @league.dues_amount.zero?
      current_user.leagues << @league

      redirect_to play_dashboard_index_path
    else
      @cost_breakdown_lines = [
        { name: "#{@league.name} League Fees", price: @league.dues_amount },
        { name: "Credit Card Fees", price: Stripe::StripeFees.fees_for_transaction_amount(@league.dues_amount) }
      ]

      @payment_amount = Payments::LeagueJoinService.payment_amount(@league)
    end
  end

  def request_information
    league = League.find(params[:league_id])

    if league.present?
      email_addresses = nil
      email_addresses = league.dues_payment_receipt_email_addresses.split(',') if league.dues_payment_receipt_email_addresses.present?
      RecordEventJob.perform_later(email_addresses, 'A user expressed league interest', { league_name: league.name, user: { first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email, phone_number: current_user.phone_number, ghin_number: current_user.ghin_number } }) if email_addresses.present?
    end

    render :thanks
  end

  def submit_payment
    league = League.find(params[:league_id])
    stripe_token = params[:stripeToken]

    begin
      Payments::LeagueJoinService.charge_and_join(current_user, league, stripe_token)

      redirect_to play_dashboard_index_path
    rescue Stripe::CardError
      redirect_to error_play_payments_path
    end
  end

  def new_league
    @league = League.new(contact_email: current_user.email, contact_name: current_user.complete_name)
    @show_apps_in_footer = false
  end

  def create_league
    @league = League.new(league_params)

    if @league.save
      LeagueMembership.create(league: @league, user: current_user, is_admin: true)

      redirect_to add_golfers_play_registrations_path(league: @league)
    else
      render :new_league
    end
  end

  def add_golfers
    @league = League.find(params[:league])
  end

  def invite_golfers
    @league = League.find(params[:golfers][:league_id])

    golfers_to_invite = params[:golfers][:golfers_to_invite].split("\n")
    golfers_to_invite.each do |g|
      UserMailer.invite(g, @league).deliver_later
    end

    SendEventToDripJob.perform_later('League admin invited golfers during registration', user: current_user, options: { number_of_golfers: golfers_to_invite.count, league_name: @league.name })

    redirect_to play_dashboard_index_path
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def league_params
    params.require(:league).permit!
  end
end
