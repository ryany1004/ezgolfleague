class DashboardController < BaseController
	def index
		@next_tournament = Tournament.all_upcoming(current_user.leagues_admin).first

		@league_season = current_user.active_league_season
		@ranking_groups = @league_season.league_season_ranking_groups
	end
end
