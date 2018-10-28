class PaymentsController < BaseController
  before_action :fetch_collections, :except => [:index]
  before_action :fetch_payment, only: [:edit, :update, :destroy]
  before_action :payment_options, only: [:new, :edit]
  
  def index
    if current_user.is_super_user?
      @payments = Payment.order("created_at DESC").page params[:page]

      @page_title = "All Payments"
    else
      selected_league = self.selected_league

      league_season_ids = selected_league.league_seasons.map {|n| n.id}    
      tournament_ids = selected_league.tournaments.map {|n| n.id}
    
      @payments = Payment.where("league_season_id IN (?) OR tournament_id IN (?)", league_season_ids, tournament_ids).page params[:page]
  
      @page_title = "#{selected_league.name} Payments"
    end
  end
  
  def new
    @payment = Payment.new
  end
  
  def create
    @payment = Payment.new(payment_params)
    
    if @payment.save
      unless @payment.league_season.blank?
        Payment.create(payment_amount: (@payment.payment_amount * -1.0), user: @payment.user, payment_type: "#{@payment.user.complete_name} League Dues", league_season: @payment.league_season)
      end
      
      redirect_to payments_path, flash: { success: "The payment was successfully created." }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def payment_options
    @payment_options = [ "Check", "Cash", "Other" ]
  end
  
  def update
    if @payment.update(payment_params)
      redirect_to payments_path, flash: { success: "The payment was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @payment.destroy
    
    redirect_to payments_path, flash: { success: "The payment was successfully deleted." }
  end
  
  def show
    @payment = Payment.find(params[:id])
    
    if current_user.is_super_user?
      @payments = @payment.user.payments
    else      
      @payments = @payment.user.payments.where("league_id = ?", self.selected_league.id)
    end
  end
  
  def payment_params
    params.require(:payment).permit(:user_id, :payment_amount, :league_season_id, :tournament_id, :payment_details, :payment_source)
  end
  
  def selected_league
    selected_league = current_user.leagues_admin.first
    selected_league = current_user.leagues_admin.find(params[:league_id]) unless params[:league_id].blank?
    
    return selected_league
  end
  
  private
  
  def fetch_payment
    #TODO: update for secure fetching
    @payment = Payment.find(params[:id])
  end
  
  def fetch_collections
    if current_user.is_super_user?
      @users = User.all.order("last_name, first_name")
      @tournaments = Tournament.all.order("signup_closes_at DESC")
      @league_seasons = LeagueSeason.all.order("starts_at DESC")
    else
      selected_league = self.selected_league
      
      @users = selected_league.users.order("last_name, first_name")
      @tournaments = selected_league.tournaments.order("signup_closes_at DESC")
      @league_seasons = LeagueSeason.where("league_id = ?", selected_league.id).order("starts_at DESC")
    end
  end
  
end
