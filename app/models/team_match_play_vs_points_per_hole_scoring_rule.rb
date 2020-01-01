class TeamMatchPlayVsPointsPerHoleScoringRule < TeamMatchPlayVsScoringRule
  def name
    'Team Match Play (vs. Opposing Player) Points Per Hole'
  end

  def description
    'Team match play where players are matched against a player on another team to compete hole-by-hole. Based on net scores, two points are awarded for a win, 1 each for a tie and 0 for a loss.'
  end

  def scoring_computer
    ScoringComputer::TeamMatchPlayVsPointsPerHoleScoringComputer.new(self)
  end

  def payout_type
    ScoringRulePayoutType::POT
  end

  def match_play_scorecard_for_user(user)
    scorecard = ScoringRuleScorecards::TeamMatchPlayPointsPerHoleScorecard.new
    scorecard.user = user
    scorecard.opponent = opponent_for_user(user)
    scorecard.scoring_rule = self

    scorecard
  end
end
