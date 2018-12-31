class DashboardController < BaseController
	def index
		@next_tournament = Tournament.all_upcoming(current_user.leagues_admin).limit(1).first
		@previous_tournament = Tournament.all_past(current_user.leagues_admin).reorder(tournament_starts_at: :desc).limit(1).first

		@league_season = current_user.active_league_season
		@ranking_groups = @league_season.league_season_ranking_groups
	end
end
