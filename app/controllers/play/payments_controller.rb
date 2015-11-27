class Play::PaymentsController < BaseController
  layout "golfer"
  
  def index
  end
  
  def new
    if params[:payment_type] == 'league_dues'
      @league = League.find(params[:league_id])
      
      @payment_instructions = "Thanks for paying your league dues via EZ Golf League. Please enter your information below."
      @payment_amount = @league.dues_for_user(current_user)
      @cost_breakdown_lines = @league.cost_breakdown_for_user(current_user)
    elsif params[:payment_type] == 'contest_dues'
      @contest = Contest.find(params[:contest_id])
      
      @payment_instructions = "Thanks for paying your contest dues via EZ Golf League. Please enter your information below."
      @payment_amount = @contest.dues_for_user(current_user)
      @cost_breakdown_lines = @contest.cost_breakdown_for_user(current_user)
    elsif params[:payment_type] == 'tournament_dues'
      @tournament = Tournament.find(params[:tournament_id])
      
      @payment_instructions = "Thanks for paying your tournament dues via EZ Golf League. Please enter your information below."
      @payment_amount = @tournament.dues_for_user(current_user)
      @cost_breakdown_lines = @tournament.cost_breakdown_for_user(current_user)      
      
      #add in any contest dues required
      @tournament.paid_contests.each do |c|
        if c.users.include? current_user
          @payment_amount += c.dues_amount
        end
      end
    else
      @payment_instructions = "Thanks for paying via EZ Golf League. Please enter your information below."
    end
  end
    
  def create
    if params[:tournament_id] != nil
      tournament = Tournament.find(params[:tournament_id])
      
      amount = tournament.dues_for_user(current_user)
      api_key = tournament.league.stripe_secret_key
      charge_description = "#{current_user.complete_name} Tournament: #{tournament.name}"
    elsif params[:contest_id] != nil
      contest = Contest.find(params[:contest_id])
      
      amount = contest.dues_for_user(current_user)
      api_key = contest.tournament_day.tournament.league.stripe_secret_key
      charge_description = "#{current_user.complete_name} Contest Dues"
    elsif params[:league_id] != nil
      league = League.find(params[:league_id])
      league_season = league.league_seasons.last
      
      amount = league.dues_for_user(current_user)
      api_key = league.stripe_secret_key
      charge_description = "#{current_user.complete_name} League Dues"
      
      Payment.create(payment_amount: (amount * -1.0), user: current_user, payment_type: charge_description, league_season: league_season)
    end
    
    Stripe.api_key = api_key

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

    Rails.logger.debug { "Sending Stripe Charge: #{amount}" }

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        :amount => (amount * 100).to_i, # amount in cents
        :currency => "usd",
        :source => token,
        :description => charge_description
      )
      
      #create payment record
      p = Payment.new(payment_amount: amount, user: current_user, payment_type: charge_description, payment_source: PAYMENT_METHOD_CREDIT_CARD)
      p.transaction_id = charge.id
      p.tournament = tournament unless tournament.blank?
      p.league_season = league_season unless league_season.blank?
      p.contest = contest unless contest.blank?
      p.save
      
      unless contest.blank?
        contest.users << current_user unless contest.users.include? current_user
      end
      
      redirect_to thank_you_play_payments_path
    rescue Stripe::CardError => e
      redirect_to error_play_payments_path
    end
  end
  
  def thank_you
  end
  
  def error
  end
  
end
