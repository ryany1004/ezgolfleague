class PaymentsController < BaseController
  
  def index
    if current_user.is_super_user?
      @payments = Payment.order("created_at DESC").page params[:page]

      @page_title = "All Payments"
    else
      selected_league = current_user.leagues.first
      selected_league = current_user.leagues.find(params[:league_id]) unless params[:league_id].blank?
    
      tournament_ids = selected_league.tournaments.map {|n| n.id}
    
      @payments = Payment.where("league_id = ? OR tournament_id IN (?)", selected_league.id, tournament_ids).page params[:page]
  
      @page_title = "#{selected_league.name} Payments"
    end
  end
  
  def show
    @payment = Payment.find(params[:id])
  end
  
end
