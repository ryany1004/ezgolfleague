class Play::PaymentsController < BaseController
  layout "golfer"
  
  def new
    if params[:payment_type] == 'league_dues'
      @league = League.find(params[:league_id])
      
      @payment_instructions = "Thanks for paying your league dues via EZ Golf League. Please enter your information below."
      @payment_amount = @league.dues_amount
    elsif params[:payment_type] == 'tournament_dues'
      @tournament = Tournament.find(params[:tournament_id])
      
      @payment_instructions = "Thanks for paying your tournament dues via EZ Golf League. Please enter your information below."
      @payment_amount = @tournament.dues_amount
    else
      @payment_instructions = "Thanks for paying via EZ Golf League. Please enter your information below."
    end
  end
  
  def create
    if params[:tournament_id] != nil
      tournament = Tournament.find(params[:tournament_id])
      
      amount = tournament.dues_amount
      api_key = tournament.league.stripe_secret_key
      charge_description = "Tournament: #{tournament.name}"
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
        :amount => (amount * 10).to_i, # amount in cents, again
        :currency => "usd",
        :source => token,
        :description => charge_description
      )
      
      #create payment record
      p = Payment.new(payment_amount: amount, user: current_user, payment_method: charge_description, payment_method: PAYMENT_METHOD_CREDIT_CARD)
      p.transaction_id = charge.id
      p.tournament = tournament unless tournament.blank?
      p.league = league unless league.blank?
      p.save
      
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
