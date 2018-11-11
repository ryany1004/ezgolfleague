class StrokePlayScoringRule < ScoringRule
	include ::StrokePlayScoringRuleSetup
	include ::StrokePlayScorecardSupport
	include ::StrokePlayScoringRuleScoring

	def name
		"Individual Stroke Play"
	end

	def can_be_played?
	  return true if self.tournament_day.data_was_imported == true

	  return false if self.tournament_day.tournament_groups.count == 0
	  return false if self.tournament_day.flights.count == 0
	  return false if self.tournament_day.course_holes.count == 0

	  true
	end
end