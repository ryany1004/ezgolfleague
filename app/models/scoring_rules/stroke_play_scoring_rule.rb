class StrokePlayScoringRule < ScoringRule
	include ::StrokePlayScoringRuleSetup
	include ::StrokePlayScorecardSupport

	def name
		"Individual Stroke Play"
	end

	def scoring_computer
		ScoringComputer::StrokePlayScoringComputer.new(self)
	end

	def show_other_scorecards?
		true
	end
end