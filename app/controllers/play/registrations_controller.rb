class Play::RegistrationsController < BaseController
  include Devise::Controllers::Helpers

  layout "golfer"

  skip_before_action :authenticate_user!

  def new
    @user_account = User.new
  end

  def create
    @user_account = User.new(user_params)

    if @user_account.save
      Delayed::Job.enqueue GhinUpdateJob.new([@user_account]) unless @user_account.ghin_number.blank?

      sign_in(@user_account, scope: :user)

      redirect_to leagues_play_registrations_path, :flash => { :success => "Your account was created." }
    else
      render :new
    end
  end

  def leagues
  end

  def search_leagues
    search_term = "%#{params[:search].downcase}%"

    @leagues = League.where(show_in_search: true).where("lower(name) LIKE ? OR lower(location) LIKE ?", search_term, search_term)
  end

  def league_info
    @league = League.find(params[:league_id])
    @upcoming_tournaments = Tournament.all_upcoming([@league], nil)
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
    @league = League.new(contact_email: current_user.email)
  end

  def create_league
    @league = League.new(league_params)
    @league.exempt_from_subscription = true unless @league.name.include? "subscription-test" #TODO: REMOVE

    if @league.save
      LeagueMembership.create(league: @league, user: current_user, is_admin: true)

      if @league.exempt_from_subscription
        redirect_to setup_completed_play_registrations_path
      else
        redirect_to information_league_subscription_credits_path(@league)
      end
    else
      render :new_league
    end
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def league_params
    params.require(:league).permit!
  end
end
