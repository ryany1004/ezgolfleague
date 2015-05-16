class PayoutsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_flight
  before_filter :fetch_payout, :only => [:edit, :update, :destroy]
  before_filter :fetch_payouts, :only => [:index]
  before_filter :set_stage
  
  def index
  end
  
  def new
    @payout = Payout.new
    @payout.amount = 0.0
    @payout.points = 0
  end
  
  def create
    @payout = Payout.new(payout_params)
    @payout.flight = @flight
    
    if @payout.save
      redirect_to league_tournament_flight_payouts_path(@tournament.league, @tournament, @flight), :flash => { :success => "The payout was successfully created." }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @payout.update(payout_params)
      redirect_to league_tournament_flight_payouts_path(@tournament.league, @tournament, @flight), :flash => { :success => "The payout was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @payout.destroy
    
    redirect_to league_tournament_flight_payouts_path(@tournament.league, @tournament, @flight), :flash => { :success => "The payout was successfully deleted." }
  end
  
  private
  
  def set_stage
    @stage_name = "flights"
  end
  
  def payout_params
    params.require(:payout).permit(:amount, :points, :sort_order)
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def fetch_payouts
    @payouts = @flight.payouts
  end
  
  def fetch_payout
    @payout = @flight.payouts.find(params[:id])
  end
  
  def fetch_flight
    @flight = @tournament.flights.find(params[:flight_id])
  end
  
end
