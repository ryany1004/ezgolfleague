class TeamStrokePlayIndividualSumScoringRule < StrokePlayScoringRule
	def name
		"Team Stroke Play"
	end

	def description
		"Team stroke play where each team score is the sum of individual scores of each player."
	end

	def team_type
		ScoringRuleTeamType::LEAGUE
	end

	def users_per_league_team
		2
	end

	def flight_based_payouts?
		false
	end

	def can_be_played?
	  return false if self.tournament_day.scorecard_base_scoring_rule.blank?

	  true
	end

	def can_be_finalized?
		return false if self.payouts.size.zero?
		return false if !self.tournament_day.has_scores?
		return false if self.users.count == 0

		true
	end

	def finalization_blockers
		blockers = []

		blockers << "#{self.name}: There are no payouts setup." if self.payouts.size == 0
		blockers << "#{self.name}: This tournament day has no scores." if !self.tournament_day.has_scores?
		blockers << "#{self.name}: There are no users for this game type." if self.users.count == 0

		blockers
	end

	def scoring_computer
		ScoringComputer::TeamStrokePlaySumScoresScoringComputer.new(self)
	end
end