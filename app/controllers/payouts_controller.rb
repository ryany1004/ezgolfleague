class PayoutsController < BaseController
  before_filter :fetch_tournament
  before_filter :fetch_payout, :only => [:edit, :update, :destroy]
  before_filter :fetch_tournament_day
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

    if @payout.save
      if params[:commit] == "Save & Continue"
        redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The payout was successfully created." }
      else
        redirect_to new_league_tournament_payout_path(@tournament.league, @tournament, tournament_day: @payout.flight.tournament_day), :flash => { :success => "The payout was successfully created." }
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @payout.update(payout_params)
      redirect_to league_tournament_payouts_path(@tournament.league, @tournament, tournament_day: @payout.flight.tournament_day), :flash => { :success => "The payout was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @payout.destroy

    redirect_to league_tournament_payouts_path(@tournament.league, @tournament, tournament_day: @payout.flight.tournament_day), :flash => { :success => "The payout was successfully deleted." }
  end

  private

  def set_stage
    if params[:tournament_day].blank?
      if @tournament.tournament_days.count > 1
        @stage_name = "payouts#{@tournament.first_day.id}"
      else
        @stage_name = "payouts"
      end
    else
      @stage_name = "payouts#{@tournament_day.id}"
    end
  end

  def payout_params
    params.require(:payout).permit(:flight_id, :amount, :points, :sort_order)
  end

  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def fetch_payouts
    if @flight.blank?
      @payouts = []

      @tournament_day.flights.each do |f|
        @payouts += f.payouts
      end
    else
      @payouts = @flight.payouts
    end
  end

  def fetch_payout
    @payout = Payout.find(params[:id])
  end

  def fetch_tournament_day
    unless @payout.blank?
      @tournament_day = @payout.flight.tournament_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day]) unless params[:tournament_day].blank?
    end

    @tournament_day = @tournament.tournament_days.first if @tournament_day.blank?
  end

end
