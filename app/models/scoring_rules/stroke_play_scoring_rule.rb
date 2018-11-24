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

	def scorecard_api(scorecard:)
    handicap_allowance = self.handicap_allowance(scorecard.golf_outing.user)

		Scorecards::Api::ScorecardAPIBase.new(scorecard.tournament_day, scorecard, handicap_allowance)
	end
end