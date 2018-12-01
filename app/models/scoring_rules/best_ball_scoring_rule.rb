class BestBallScoringRule < ScoringRule
	def name
		"Best Ball"
	end

	def team_type
		ScoringRuleTeamType::DAILY
	end
end