class DashboardController < BaseController
  def index
    @next_tournament = Tournament.next_unfinalized([current_user.selected_league])
    @previous_tournament = Tournament.all_past([current_user.selected_league]).reorder(tournament_starts_at: :desc).limit(1).first

    @league_season = current_user.active_league_season
    @ranking_groups = @league_season.league_season_ranking_groups
  end

  def switch_leagues
    league = view_league_from_user_for_league_id(params[:league_id])
    current_user.current_league = league
    current_user.save

    session[:selected_season_id] = nil

  redirect_to dashboard_index_path
  end
end
