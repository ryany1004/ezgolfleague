class PaymentsController < BaseController
  before_filter :fetch_collections, :except => [:index]
  before_filter :fetch_payment, :only => [:edit, :update, :destroy]
  
  def index
    if current_user.is_super_user?
      @payments = Payment.order("created_at DESC").page params[:page]

      @page_title = "All Payments"
    else
      selected_league = self.selected_league
    
      tournament_ids = selected_league.tournaments.map {|n| n.id}
    
      @payments = Payment.where("league_id = ? OR tournament_id IN (?)", selected_league.id, tournament_ids).page params[:page]
  
      @page_title = "#{selected_league.name} Payments"
    end
  end
  
  def new
    @payment = Payment.new
  end
  
  def create
    @payment = Payment.new(payment_params)
    
    if @payment.save
      redirect_to payments_path, :flash => { :success => "The payment was successfully created." }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @payment.update(payment_params)
      redirect_to payments_path, :flash => { :success => "The payment was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @payment.destroy
    
    redirect_to payments_path, :flash => { :success => "The payment was successfully deleted." }
  end
  
  def show
    @payment = Payment.find(params[:id])
  end
  
  def payment_params
    params.require(:payment).permit(:user_id, :payment_amount, :league_id, :tournament_id, :payment_details)
  end
  
  def selected_league
    selected_league = current_user.leagues.first
    selected_league = current_user.leagues.find(params[:league_id]) unless params[:league_id].blank?
    
    return selected_league
  end
  
  private
  
  def fetch_payment
    @payment = Payment.find(params[:id])
  end
  
  def fetch_collections
    if current_user.is_super_user?
      @users = User.all.order("last_name, first_name")
      @tournaments = Tournament.all.order("signup_closes_at DESC")
      @leagues = League.all.order("name")
    else
      selected_league = self.selected_league
      
      @users = selected_league.users.order("last_name, first_name")
      @tournaments = selected_league.tournaments.order("signup_closes_at DESC")
      @leagues = League.where("id = ?", selected_league.id)
    end
  end
  
end
