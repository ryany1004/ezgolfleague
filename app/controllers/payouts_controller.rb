class PayoutsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_tournament_day
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
      redirect_to league_tournament_flight_payouts_path(@tournament.league, @tournament, @flight, tournament_day: @flight.tournament_day), :flash => { :success => "The payout was successfully created." }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @payout.update(payout_params)
      redirect_to league_tournament_flight_payouts_path(@tournament.league, @tournament, @flight, tournament_day: @flight.tournament_day), :flash => { :success => "The payout was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @payout.destroy
    
    redirect_to league_tournament_flight_payouts_path(@tournament.league, @tournament, @flight, tournament_day: @flight.tournament_day), :flash => { :success => "The payout was successfully deleted." }
  end
  
  private
  
  def set_stage
    if params[:tournament_day].blank?
      if @tournament.tournament_days.count > 1
        @stage_name = "flights#{@tournament.first_day.id}"
      else
        @stage_name = "flights"
      end
    else
      @stage_name = "flights#{@tournament_day.id}"
    end
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
  
  def fetch_tournament_day
    if params[:tournament_day].blank?
      if params[:tournament_day_id].blank?
        @tournament_day = @tournament.first_day
      else
        @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
      end
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
  end
  
  def fetch_flight
    @flight = @tournament_day.flights.find(params[:flight_id])
  end
  
end
