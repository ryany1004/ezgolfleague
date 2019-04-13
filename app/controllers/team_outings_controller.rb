class TeamOutingsController < BaseController
  before_action :fetch_tournament
  before_action :set_stage

  def teams
    @page_title = "Matchups for #{@tournament.name}"
    
    @tournament_day.create_league_season_team_matchups

    @registered_teams = @tournament.teams_for_day(@tournament_day)
  end

  def update_teams
    @matchup = @tournament_day.league_season_team_tournament_day_matchups.find(params[:team_submit][:matchup_id])

    updater = Updaters::TournamentGroupTeamUpdater.new
    @teams_signed_up = updater.update_for_params(@tournament_day, @matchup, params)

    @outing_index = []
    @teams_signed_up.each do |p|
      @outing_index << { id: p.id }
    end
  end

  def delete_team_signup
    matchup = LeagueSeasonTeamTournamentDayMatchup.find(params[:matchup_id])
    team = LeagueSeasonTeam.find(params[:team_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end

    @tournament_day.remove_league_season_team(matchup, team)

    redirect_to league_tournament_day_teams_path(@tournament.league, @tournament, @tournament_day), flash: { success: "The team was successfully deleted." }
  end

  def team
  	@league_season_team = league_season_team
  end

  def toggle_player
  	player = @league.users.find(params[:player_id])
  	matchup = @tournament_day.league_season_team_matchup_for_team(league_season_team)
  	matchup.toggle_user(player)

  	redirect_to league_tournament_day_team_path(@league, @tournament, @tournament_day, league_season_team)
  end

  private

  def league_season_team
  	@league_season_team ||= @tournament.league_season.league_season_teams.find(params[:team_id])
  end

  def set_stage
    @stage_name = "teams#{@tournament_day.id}"
  end

  def fetch_tournament
    @league = self.league_from_user_for_league_id(params[:league_id])
    @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @all_teams = @tournament.league_season.league_season_teams
  end
end
