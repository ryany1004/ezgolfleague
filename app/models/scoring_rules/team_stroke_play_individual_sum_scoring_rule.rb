class TeamStrokePlayIndividualSumScoringRule < StrokePlayScoringRule
	def name
		"Team Stroke Play"
	end

	def description
		"Team stroke play where each team score is the sum of individual scores."
	end

	def team_type
		ScoringRuleTeamType::LEAGUE
	end

	def users_per_league_team
		2
	end
end