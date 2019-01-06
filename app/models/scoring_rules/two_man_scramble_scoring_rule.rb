class TwoManScrambleScoringRule < ScrambleScoringRule
	def name
		"Two-Man Scramble"
	end

	def users_per_daily_team
		2
	end

	def legacy_game_type_id
		7
	end
end