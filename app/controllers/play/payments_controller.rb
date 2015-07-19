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
  end
  
  def thank_you
  end
  
end
