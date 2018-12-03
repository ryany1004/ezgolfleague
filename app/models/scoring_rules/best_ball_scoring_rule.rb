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
    # scorecard.course_hole_number_suppression_list = self.course_hole_number_suppression_list
    scorecard.user = user
    scorecard.scoring_rule = self
    scorecard.daily_team = daily_team
    scorecard.should_use_handicap = use_handicaps
    scorecard.calculate_scores

    return scorecard
  end
end