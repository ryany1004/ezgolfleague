class Play::PaymentsController < BaseController
  layout "golfer"
  
  def index
  end
  
  def new
    if params[:payment_type] == 'league_dues'
      @league = League.find(params[:league_id])
      
      @payment_instructions = "Thanks for paying your league dues via EZ Golf League. Please enter your information below."
      @payment_amount = @league.dues_amount - current_user.discount_amount_for_league(@league)
    elsif params[:payment_type] == 'contest_dues'
      @contest = Contest.find(params[:contest_id])
      @league = @contest.tournament_day.tournament.league
      
      @payment_instructions = "Thanks for paying your contest dues via EZ Golf League. Please enter your information below."
      @payment_amount = @contest.dues_amount
    elsif params[:payment_type] == 'tournament_dues'
      @tournament = Tournament.find(params[:tournament_id])
      @league = @tournament.league
      
      @payment_instructions = "Thanks for paying your tournament dues via EZ Golf League. Please enter your information below."
      @payment_amount = @tournament.dues_amount
      
      #add in any contest dues required
      @tournament.paid_contests.each do |c|
        if c.users.include? current_user
          @payment_amount += c.dues_amount
        end
      end
    else
      @payment_instructions = "Thanks for paying via EZ Golf League. Please enter your information below."
    end
    
    unless @league.blank? #add fee percentage
      credit_card_fee_amount = @league.credit_card_fee_percentage * @payment_amount
      @payment_amount = @payment_amount + credit_card_fee_amount
      
      @payment_instructions = @payment_instructions + " Your dues amount includes a credit card processing fee."
    end
  end
  
  def create
    if params[:tournament_id] != nil
      tournament = Tournament.find(params[:tournament_id])
      
      amount = tournament.dues_amount
      api_key = tournament.league.stripe_secret_key
      charge_description = "Tournament: #{tournament.name}"
    elsif params[:contest_id] != nil
      contest = Contest.find(params[:contest_id])
      
      amount = contest.dues_amount
      api_key = contest.tournament_day.tournament.league.stripe_secret_key
      charge_description = "Contest Dues"
    elsif params[:league_id] != nil
      league = League.find(params[:league_id])
      
      amount = league.dues_amount
      api_key = league.stripe_secret_key
      charge_description = "League Dues"
    end
    
    Stripe.api_key = api_key

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

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
      p.league = league unless league.blank?
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
