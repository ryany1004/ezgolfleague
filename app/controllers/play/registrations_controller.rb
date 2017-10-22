class Play::RegistrationsController < Play::BaseController
  include Devise::Controllers::Helpers

  layout "golfer"

  skip_before_action :authenticate_user!

  def new
    @user_account = User.new

    @show_apps_in_footer = false
  end

  def create
    @user_account = User.new(user_params)
    @show_apps_in_footer = false

    if @user_account.save
      Delayed::Job.enqueue GhinUpdateJob.new([@user_account]) unless @user_account.ghin_number.blank?

      UserMailer.welcome(@user_account).deliver_later

      sign_in(@user_account, scope: :user)

      redirect_to leagues_play_registrations_path, :flash => { :success => "Your account was created." }
    else
      render :new
    end
  end

  def leagues
    @show_apps_in_footer = false

    @leagues = League.where(show_in_search: true).order(:name)
  end

  def join_league
    @league = League.find(params[:league_id])

    if @league.dues_amount == 0.0
      current_user.leagues << @league

      redirect_to setup_completed_play_registrations_path
    else
      @cost_breakdown_lines = [
        {:name => "#{@league.name} League Fees", :price => @league.dues_amount},
        {:name => "Credit Card Fees", :price => Stripe::StripeFees.fees_for_transaction_amount(@league.dues_amount)}
      ]

      @payment_amount = Payments::LeagueJoinService.payment_amount(@league)
    end
  end

  def request_information
    league = League.find(params[:league_id])

    LeagueMailer.league_interest(current_user, league).deliver_later unless league.blank?

    render :thanks
  end

  def submit_payment
    league = League.find(params[:league_id])
    stripe_token = params[:stripeToken]

    begin
      Payments::LeagueJoinService.charge_and_join(current_user, league, stripe_token)

      redirect_to setup_completed_play_registrations_path
    rescue Stripe::CardError => e
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

    params[:golfers][:golfers_to_invite].split("\n").each do |g|
      UserMailer.invite(g, @league).deliver_later
    end

    redirect_to setup_completed_play_registrations_path
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def league_params
    params.require(:league).permit!
  end
end
