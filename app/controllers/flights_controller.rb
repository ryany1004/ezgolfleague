class FlightsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_flights, :only => [:index, :edit, :update]
  before_filter :fetch_flight, :only => [:edit, :update, :destroy]
  
  def index
  end
  
  def new
    @flight = Flight.new
    
    if @tournament.flights.count > 0
      @flight.flight_number = @tournament.flights.last.flight_number + 1
      @flight.lower_bound = @tournament.flights.last.upper_bound + 1
    else
      @flight.flight_number = 1
      @flight.lower_bound = 0
    end
  end
  
  def create
    @flight = Flight.new(flight_params)
    @flight.tournament = @tournament
    
    if @flight.save
      self.update_player_flight_membership
      
      redirect_to league_tournament_flights_path(@tournament.league, @tournament), :flash => { :success => "The flight was successfully created." }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @flight.update(flight_params)
      self.update_player_flight_membership
      
      redirect_to league_tournament_flights_path(@tournament.league, @tournament), :flash => { :success => "The flight was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @flight.destroy
    
    redirect_to league_tournament_flights_path(@tournament.league, @tournament), :flash => { :success => "The flight was successfully deleted." }
  end
  
  def update_player_flight_membership
    @tournament.assign_players_to_flights(false)
  end
  
  private
  
  def flight_params
    params.require(:flight).permit(:flight_number, :lower_bound, :upper_bound, :course_tee_box_id)
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def fetch_flights
    @flights = @tournament.flights
  end
  
  def fetch_flight
    @flight = @tournament.flights.find(params[:id])
  end
  
end
