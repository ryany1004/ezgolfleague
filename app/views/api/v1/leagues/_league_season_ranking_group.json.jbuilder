json.cache! ['v1', league_season_ranking_group] do
	json.name 									league_season_ranking_group.name
	json.server_id							league_season_ranking_group.server_id
	
	json.league_season_rankings league_season_ranking_group.league_season_rankings do |league_season_ranking|
		json.name 									league_season_ranking.name
		json.server_id							league_season_ranking.server_id
		json.points									league_season_ranking.points
		json.payouts								league_season_ranking.payouts
		json.rank										league_season_ranking.rank

		json.user do
			json.id										league_season_ranking.user.server_id
		end
	end
end