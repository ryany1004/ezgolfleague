class LeagueSeasonRanking < ApplicationRecord
	include Servable
	
	belongs_to :league_season_ranking_group, inverse_of: :league_season_rankings
	belongs_to :user

	def name
		user.complete_name
	end
end
