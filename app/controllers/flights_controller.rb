class FlightsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_tournament_day
  before_filter :fetch_flights, :only => [:index, :edit, :update]
  before_filter :fetch_flight, :only => [:edit, :update, :destroy]
  before_filter :set_stage
  
  def index
    @page_title = "Flights for #{@tournament.name} #{@tournament_day.pretty_day}"
  end
  
  def new
    @flight = Flight.new
    
    if @tournament_day.flights.count > 0
      @flight.flight_number = @tournament_day.flights.last.flight_number + 1
      @flight.lower_bound = @tournament_day.flights.last.upper_bound + 1
    else
      @flight.flight_number = 1
      @flight.lower_bound = 0
    end
  end
  
  def create
    @flight = Flight.new(flight_params)
    @flight.tournament_day = @tournament_day
    
    if @flight.save
      self.update_player_flight_membership
      
      if params[:commit] == "Save & Continue"
        if @tournament_day.show_teams? == true
          redirect_to league_tournament_golfer_teams_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The flight was successfully created." }
        else
          redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The flight was successfully created. Please specify any contest info." }
        end
      else
        redirect_to league_tournament_flights_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The flight was successfully created." }
      end 
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @flight.update(flight_params)
      self.update_player_flight_membership
      
      redirect_to league_tournament_flights_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The flight was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @flight.destroy
    
    redirect_to league_tournament_flights_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The flight was successfully deleted." }
  end
  
  def reflight_players
    self.update_player_flight_membership
    
    redirect_to league_tournament_flights_path(@tournament.league, @tournament), :flash => { :success => "The players were re-flighted." }
  end
  
  def update_player_flight_membership
    @tournament_day.assign_players_to_flights(false)
  end
  
  private
  
  def flight_params
    params.require(:flight).permit(:flight_number, :lower_bound, :upper_bound, :course_tee_box_id)
  end
  
  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def fetch_flights
    @flights = @tournament_day.flights
  end
  
  def fetch_flight
    @flight = @tournament_day.flights.find(params[:id])
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
  
end
