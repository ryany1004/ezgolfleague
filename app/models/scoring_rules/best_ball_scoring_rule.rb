class BestBallScoringRule < StrokePlayScoringRule
	include ::BestBallScorecardSupport

	def name
		"Best Ball"
	end

	def description
		"The best ball on each hole for each team is used for scoring."
	end

	def team_type
		ScoringRuleTeamType::DAILY
	end

	def scoring_computer
		ScoringComputer::BestBallScoringComputer.new(self)
	end

  def best_ball_scorecard_for_user_in_team(user, daily_team, use_handicaps)
    scorecard = ScoringRuleScorecards::BestBallScorecard.new
    scorecard.user = user
    scorecard.scoring_rule = self
    scorecard.users_to_compare = daily_team.users if daily_team.present?
    scorecard.should_use_handicap = use_handicaps
    scorecard.calculate_scores

    return scorecard
  end

	def scorecard_api(scorecard:)
    handicap_allowance = self.handicap_computer.handicap_allowance(user: scorecard.golf_outing.user)

		Scorecards::Api::ScorecardAPIBestBall.new(scorecard.tournament_day, scorecard, handicap_allowance).scorecard_representation
	end
end
