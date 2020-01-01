class TwoManBestBallScoringRule < BestBallScoringRule
	def name
		"Two Man Best Ball"
	end

	def users_per_daily_team
		2
	end

	def legacy_game_type_id
		10
	end
end