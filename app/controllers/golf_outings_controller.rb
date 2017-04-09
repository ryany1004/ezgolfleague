class GolfOutingsController < BaseController
  before_filter :fetch_tournament
  before_filter :set_stage

  def players
    @schedule_options = { 0 => "Manual", 1 => "Automatic: Worst Score First", 2 => "Automatic: Best Score First" }

    @page_title = "Signups for #{@tournament.name}"
  end

  def update_players
    @job = Delayed::Job.enqueue PlayerSignupJob.new(params)

    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "Your player signup submissions are being processed. This process usually takes a few minutes to complete."}
  end

  def delete_signup
    tournament_group = TournamentGroup.find(params[:group_id])
    user = User.find(params[:user_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end

    @tournament_day.remove_player_from_group(tournament_group, user, true)

    redirect_to league_tournament_day_players_path(@tournament.league, @tournament, @tournament_day), :flash => { :success => "The registration was successfully deleted." }
  end

  def disqualify_signup
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end

    user = User.find(params[:user_id])
    golf_outing = @tournament_day.golf_outing_for_player(user)
    golf_outing.disqualify

    redirect_to league_tournament_day_players_path(@tournament.league, @tournament, @tournament_day), :flash => { :success => "The player qualification status changed. You may need to re-finalize the tournament." }
  end

  private

  def set_stage
    @stage_name = "players#{@tournament_day.id}"
  end

  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = TournamentDay.find(params[:tournament_day_id])
    @tournament_groups = @tournament_day.tournament_groups

    @league_members = @tournament.league.users
  end

end
