class TournamentGroupsController < BaseController
  before_action :fetch_tournament
  before_action :fetch_tournament_day
  before_action :fetch_tournament_group, except: [:index, :new, :create, :batch_create]
  before_action :set_stage

  def index
    @tournament_groups = @tournament_day.tournament_groups.page params[:page]

    if @tournament_groups.count > 0
      @starting_tee_time = @tournament_day.tournament_groups.last.tee_time_at + 8.minutes
    else
      @starting_tee_time = @tournament_day.tournament_at
    end

    @page_title = "Tee Times for #{@tournament.name} #{@tournament_day.pretty_day}"
  end

  def new
    @tournament_group = TournamentGroup.new

    if @tournament_day.tournament_groups.count > 0
      @tournament_group.tee_time_at = @tournament_day.tournament_groups.last.tee_time_at + 8.minutes
    else
      @tournament_group.tee_time_at = @tournament_day.tournament_at
    end
  end

  def create
    @tournament_group = TournamentGroup.new(tournament_group_params)
    @tournament_group.tournament_day = @tournament_day

    if @tournament_group.save
      if params[:commit] == "Save & Continue"
        redirect_to league_tournament_tournament_day_flights_path(@tournament.league, @tournament, @tournament_day), flash: { success: "The tee time was successfully created." }
      else
        redirect_to new_league_tournament_tournament_group_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The tee time was successfully created." }
      end
    else
      render :new
    end
  end

  def update
    if @tournament_group.update(tournament_group_params)
      redirect_to league_tournament_tournament_groups_path(@tournament.league, @tournament, tournament_day: @tournament_day), flash: { success: "The tee time was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @tournament_group.destroy

    redirect_to league_tournament_tournament_day_tournament_groups_path(@tournament.league, @tournament, @tournament_day), flash: { success: "The tee time was successfully deleted." }
  end

  def batch_create
    unless params[:tournament_group].blank?
      starting_time = DateTime.strptime("#{params[:tournament_group][:starting_time]} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      tee_time = starting_time

      params[:tournament_group][:number_of_tee_times_to_create].to_i.times do |time|
        TournamentGroup.create(tournament_day: @tournament_day, max_number_of_players: params[:tournament_group][:max_number_of_players].to_i, tee_time_at: tee_time)

        tee_time = tee_time + params[:tournament_group][:separation_interval].to_i.minutes
      end
    end

    redirect_to league_tournament_tournament_day_flights_path(@tournament.league, @tournament, @tournament_day), flash: { success: "The tee times were successfully created." }
  end

  private

  def tournament_group_params
    params.require(:tournament_group).permit(:tee_time_at, :max_number_of_players)
  end

  def fetch_tournament
    @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
  end

  def fetch_tournament_group
    @tournament_group = @tournament_day.tournament_groups.find(params[:id])
  end

  def fetch_tournament_day
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end

  def set_stage
    if params[:tournament_day].blank?
      if @tournament.tournament_days.count > 1
        @stage_name = "tee_times#{@tournament.first_day.id}"
      else
        @stage_name = "tee_times"
      end
    else
      if @tournament.tournament_days.count > 1
        @stage_name = "tee_times#{@tournament_day.id}"
      else
        @stage_name = "tee_times"
      end
    end
  end

end
