class TournamentDaysController < BaseController
  before_action :set_stage
  before_action :fetch_tournament
  before_action :initialize_form, only: [:new, :edit]
  before_action :fetch_tournament_day, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @tournament_day = TournamentDay.new
    @tournament_day.tournament_at = @tournament.signup_closes_at
  end

  def create
    @tournament_day = TournamentDay.new(tournament_day_params)
    @tournament_day.tournament = @tournament
    @tournament_day.game_type_id = 1

    @tournament_day.course.course_holes.each do |ch|
      @tournament_day.course_holes << ch
    end

    @tournament_day.skip_date_validation = current_user.is_super_user

    if @tournament_day.save
      self.update_tournament_date

      if params[:commit] == "Save & Continue"
        redirect_to league_tournament_manage_holes_path(@tournament.league, @tournament), flash: { success: "The day was successfully created." }
      else
        redirect_to new_league_tournament_tournament_day_path(@tournament.league, @tournament), flash: { success: "The day was successfully created." }
      end
    else
      initialize_form

      render :new
    end
  end

  def edit
  end

  def update
    if @tournament_day.update(tournament_day_params)
      self.update_tournament_date

      redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), flash: { success: "The day was successfully updated." }
    else
      initialize_form

      render :edit
    end
  end

  def destroy
    @tournament_day.destroy

    redirect_to league_tournament_tournament_days_path(@tournament.league, @tournament), flash: { success: "The day was successfully deleted." }
  end

  def update_tournament_date
    @tournament.tournament_starts_at = @tournament.tournament_days.first.tournament_at unless @tournament.tournament_days.first.blank?
    @tournament.save
  end

  private

  def tournament_day_params
    params.require(:tournament_day).permit(:course_id, :tournament_at, :enter_scores_until_finalized, :course_hole_ids => [])
  end

  def fetch_tournament_day
    @tournament_day = @tournament.tournament_days.find(params[:id])
  end

  def fetch_tournament
    @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
  end

  def set_stage
    @stage_name = "days"
  end

  def initialize_form
    @courses = Course.all.order(:name)
  end

end
