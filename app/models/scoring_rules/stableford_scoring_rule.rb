class StablefordScoringRule < StrokePlayScoringRule
	include ::StablefordScoringRuleSetup
	include ::StablefordScorecardSupport

	def name
		"Stableford"
	end

	def description
		"Rather than counting the total number of strokes taken, it involves scoring points based on the number of strokes taken at each hole."
	end

	def legacy_game_type_id
		3
	end

	def scoring_computer
		ScoringComputer::StablefordScoringComputer.new(self)
	end

  def stableford_scorecard_for_user(user:)
    scorecard = ScoringRuleScorecards::StablefordScorecard.new
    scorecard.user = user
    scorecard.scoring_rule = self
    scorecard.calculate_scores

    return scorecard
  end
end