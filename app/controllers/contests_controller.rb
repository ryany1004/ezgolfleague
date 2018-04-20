class ContestsController < BaseController
  before_action :fetch_tournament
  before_action :fetch_tournament_day
  before_action :fetch_contests, :only => [:index]
  before_action :fetch_contest, :only => [:edit, :update, :destroy]
  before_action :setup_form, :only => [:new, :edit]
  before_action :set_stage

  def index
    @page_title = "Contests"
  end

  def new
    @contest = Contest.new
    @contest.contest_type = 0
  end

  def create
    @contest = Contest.new(contest_params)
    @contest.tournament_day = @tournament_day

    if @contest.save
      if @contest.contest_type >= 1
        if params[:commit] == "Save & Complete Tournament Setup"
          skip_to_completion = true
        else
          skip_to_completion = false
        end

        if @contest.contest_type == 1
          success_message = "The contest was successfully created. Please verify the holes involved."
        elsif @contest.contest_type >= 2
          success_message = "The contest was successfully created. Please specify the dues for each player entering."

          if @contest.is_by_hole? == true
            @tournament_day.course_holes.each do |hole|
              @contest.course_holes << hole
            end

            @contest.save
          end
        end

        redirect_to edit_league_tournament_contest_path(@tournament.league, @tournament, @contest, :skip_to_complete => skip_to_completion, tournament_day: @tournament_day), :flash => { :success => success_message }
      else
        if params[:commit] == "Save & Continue"
          redirect_to league_tournament_tournament_notifications_path(@tournament.league, @tournament), :flash => { :success => "The contest was successfully created." }
        elsif params[:commit] == "Save & Continue to Next Day"
          redirect_to league_tournament_tournament_groups_path(@tournament.league, @tournament, tournament_day: @tournament.tournament_days.last), :flash => { :success => "The contest was successfully created." }
        else
          redirect_to new_league_tournament_contest_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully created." }
        end
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @contest.update(contest_params)
      if params[:commit] == "Save & Continue"
        redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The contest was successfully updated." }
      elsif params[:commit] == "Save & Continue to Next Day"
        redirect_to league_tournament_tournament_groups_path(@tournament.league, @tournament, tournament_day: @tournament.tournament_days.last), :flash => { :success => "The contest was successfully updated." }
      else
        redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully updated." }
      end
    else
      render :edit
    end
  end

  def destroy
    @contest.destroy

    redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully deleted." }
  end

  def registrations
    @contest = Contest.find(params[:contest_id])

    @unregistered_users = @contest.users_not_signed_up
  end

  def remove_registration
    contest = Contest.find(params[:contest_id])
    user = User.find(params[:user])

    contest.remove_user(user)

    redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully updated." }
  end

  def add_registration
    unless params[:contest_registration][:another_member_id].blank?
      contest = Contest.find(params[:contest_id])
      user = User.find(params[:contest_registration][:another_member_id])

      contest.add_user(user)
    end

    redirect_to league_tournament_contests_path(@tournament.league, @tournament, tournament_day: @tournament_day), :flash => { :success => "The contest was successfully updated." }
  end

  private

  def fetch_contests
    @contests = @tournament_day.contests
  end

  def fetch_contest
    @contest = @tournament_day.contests.find(params[:id])
  end

  def fetch_tournament
    @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
  end

  def setup_form
    @contest_types = []
    @contest_types << ContestType.new("Custom: Overall Winner", 0)
    @contest_types << ContestType.new("Custom: By Hole", 1)
    @contest_types << ContestType.new("Net Skins", 2)
    @contest_types << ContestType.new("Gross Skins", 3)
    @contest_types << ContestType.new("Net Skins + Gross Skins", 8)
    @contest_types << ContestType.new("Net Low", 4)
    @contest_types << ContestType.new("Gross Low", 5)

    if @tournament.tournament_days.count > 1
      @contest_types << ContestType.new("Net Low Tournament Total", 6)
      @contest_types << ContestType.new("Gross Low Tournament Total", 7)
    end
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
        @stage_name = "contests#{@tournament.first_day.id}"
      else
        @stage_name = "contests"
      end
    else
      if @tournament.tournament_days.count > 1
        @stage_name = "contests#{@tournament_day.id}"
      else
        @stage_name = "contests"
      end
    end
  end

  def contest_params
    params.require(:contest).permit(:name, :contest_type, :dues_amount, :overall_winner_payout_amount, :overall_winner_points, :is_opt_in, :course_hole_ids => [])
  end
end

class ContestType
  attr_accessor :name
  attr_accessor :value

  def initialize(name, value)
    @name = name
    @value = value
  end
end
