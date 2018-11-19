class PayoutsController < BaseController
  before_action :fetch_tournament
  before_action :fetch_tournament_day
  before_action :fetch_payout, only: [:edit, :update, :destroy]
  before_action :fetch_payouts, only: [:index]
  before_action :set_stage

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
        redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The payout was successfully created." }
      else
        redirect_to new_league_tournament_payout_path(@tournament.league, @tournament, tournament_day: @payout.flight.tournament_day), flash: { success: "The payout was successfully created." }
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @payout.update(payout_params)
      redirect_to league_tournament_payouts_path(@tournament.league, @tournament, tournament_day: @payout.flight.tournament_day), flash: { success: "The payout was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @payout.destroy

    redirect_to league_tournament_payouts_path(@tournament.league, @tournament, tournament_day: @payout.flight.tournament_day), flash: { success: "The payout was successfully deleted." }
  end

  private

  def set_stage
    if params[:tournament_day_id].blank?
      if @tournament.tournament_days.count > 1
        @stage_name = "scoring_rules#{@tournament.first_day.id}"
      else
        @stage_name = "scoring_rules"
      end
    else
      if @tournament.tournament_days.count > 1
        @stage_name = "scoring_rules#{@tournament_day.id}"
      else
        @stage_name = "scoring_rules"
      end
    end
  end

  def payout_params
    params.require(:payout).permit(:flight_id, :amount, :points, :sort_order)
  end

  def fetch_tournament
    @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
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
    @payout = @scoring_rule.payouts.find(params[:id])
  end

  def fetch_tournament_day
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @scoring_rule = @tournament_day.scoring_rules.find(params[:scoring_rule_id])
  end

end
