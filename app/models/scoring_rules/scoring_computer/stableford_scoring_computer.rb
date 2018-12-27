module ScoringComputer
	class StablefordScoringComputer < StrokePlayScoringComputer
		
		
		def generate_tournament_day_result(user:, scorecard: nil, destroy_previous_results: true)
      scorecard = @scoring_rule.stableford_scorecard_for_user(user: user)
      return nil if scorecard.blank? || scorecard.scores.blank?

      super(user: user, scorecard: scorecard, destroy_previous_results: true)
		end
	end
end