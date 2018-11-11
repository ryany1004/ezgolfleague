class FlightsController < BaseController
  before_action :fetch_tournament
  before_action :fetch_tournament_day
  before_action :fetch_flights, only: [:index, :edit, :update]
  before_action :fetch_flight, only: [:edit, :update, :destroy]
  before_action :set_stage

  def index
    @page_title = "Flights for #{@tournament.name} #{@tournament_day.pretty_day}"

    if @tournament.league.allow_scoring_groups && @tournament_day.flights.count == 0
      @tournament_day.create_scoring_group_flights
    elsif !@tournament.league.allow_scoring_groups && @tournament_day.flights.count == 0
      @tournament_day.copy_flights_from_previous_day
    end
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
        redirect_to league_tournament_payouts_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The flight was successfully created." }
      else
        redirect_to new_league_tournament_flight_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The flight was successfully created." }
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

      redirect_to league_tournament_flights_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The flight was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @flight.destroy

    redirect_to league_tournament_flights_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The flight was successfully deleted." }
  end

  def reflight_players
    self.update_player_flight_membership

    redirect_to league_tournament_flights_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The players were re-flighted." }
  end

  def update_player_flight_membership
    @tournament_day.assign_players_to_flights
  end

  private

  def flight_params
    params.require(:flight).permit(:flight_number, :lower_bound, :upper_bound, :course_tee_box_id)
  end

  def fetch_tournament
    @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
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
      if @tournament.tournament_days.count > 1
        @stage_name = "flights#{@tournament_day.id}"
      else
        @stage_name = "flights"
      end
    end
  end

end
