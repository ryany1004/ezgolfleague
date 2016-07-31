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

        session[:temporary_user_id] = @user_account.id

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
      @user_account = temporary_user
      @league = League.find(params[:league_id])

      @cost_breakdown_lines = [
        {:name => "#{@league.name} League Fees", :price => @league.dues_amount},
        {:name => "Credit Card Fees", :price => Stripe::StripeFees.fees_for_transaction_amount(@league.dues_amount)}
      ]

      @payment_amount = Payments::LeagueJoinService.payment_amount(@league)
    end

    def request_information
      @user_account = temporary_user

      league = League.find(params[:league_id])

      LeagueMailer.league_interest(@user_account, league).deliver_later unless league.blank?

      render :thanks
    end

    def submit_payment
      @current_user = temporary_user
      league = League.find(params[:league_id])
      stripe_token = params[:stripeToken]

      begin
        Payments::LeagueJoinService.charge_and_join(@current_user, league, stripe_token)

        sign_in(@current_user)

        redirect_to play_dashboard_index_path, :flash => { :success => "You have joined the league." }
      rescue Stripe::CardError => e
        redirect_to error_play_payments_path
      end
    end

    private

    def user_params
      params.require(:user).permit!
    end

    def temporary_user
      User.where(id: session[:temporary_user_id]).first
    end
end
