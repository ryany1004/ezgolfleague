module DashboardHelper
	def current_league_golfers
		current_user.selected_league.users.count
	end

	def current_league_season_tournaments
		current_user.selected_league.active_season.tournaments.count
	end

	def registration_is_open?(tournament)
		if DateTime.now >= tournament.signup_opens_at && DateTime.now < tournament.signup_closes_at
			true
		else
			false
		end
	end
end
