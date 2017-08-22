class GolfOutingsController < BaseController
  before_action :fetch_tournament
  before_action :set_stage

  def players
    @schedule_options = { 0 => "Manual", 1 => "Automatic: Worst Score First", 2 => "Automatic: Best Score First" }
    @page_title = "Signups for #{@tournament.name}"
    @registered_players = @tournament.players_for_day(@tournament_day)
  end

  def update_players
    self.submit_updates(params)
  end

  def move_group
    group_id = params[:group][:groupID]
    player_ids = params[:group][:players]

    group = @tournament_groups.where(id: group_id).first
    player_ids.each do |player_id|
      if group.golf_outings.where(user_id: player_id).blank?
        user = User.where(id: player_id).first
        existing_outing = @tournament_day.golf_outing_for_player(user)

        unless existing_outing.blank? || user.blank?
          @tournament_day.move_player_to_tournament_group(user, group)
        end
      end
    end

    render json: {"success" => true}
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

  def submit_updates(params)
    @tournament_group = @tournament_day.tournament_groups.find(params[:tournament_group_id])

    updater = Updaters::TournamentGroupUpdater.new
    @players_signed_up = updater.update_for_params(@tournament_group, params)

    @outing_index = []
    @players_signed_up.each do |p|
      golf_outing = @tournament_day.golf_outing_for_player(p)
      disqualificationText = golf_outing.disqualification_description

      @outing_index << {id: p.id, dqText: disqualificationText}
    end
  end
  handle_asynchronously :submit_updates

  private

  def set_stage
    @stage_name = "players#{@tournament_day.id}"
  end

  def fetch_tournament
    @league = League.find(params[:league_id])
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = TournamentDay.find(params[:tournament_day_id])
    @tournament_groups = @tournament_day.tournament_groups
    @all_league_members = @tournament.league.users
  end

end
