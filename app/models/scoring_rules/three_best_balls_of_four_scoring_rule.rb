class ThreeBestBallsOfFourScoringRule < StrokePlayScoringRule
  include ::ThreeBestBallsOfFourScorecardSupport
  include ::ThreeBestBallsOfFourScoringRuleSetup

  def name
    'Individual 3 Best Balls of 4'
  end

  def description
    'The three best net scores of the four are summed to determine the score for the hole.'
  end

  def team_type
    ScoringRuleTeamType::DAILY
  end

  def users_per_daily_team
    4
  end

  def scoring_computer
    ScoringComputer::BestBallScoringComputer.new(self)
  end

  def best_ball_scorecard_for_user_in_team(user, daily_team, use_handicaps)
    scorecard = ScoringRuleScorecards::ThreeBestBallsOfFourScorecard.new
    scorecard.user = user
    scorecard.scoring_rule = self
    scorecard.users_to_compare = daily_team.users if daily_team.present?
    scorecard.should_use_handicap = use_handicaps
    scorecard.calculate_scores

    scorecard
  end

  def include_ghost_par_scores?(users)
    if should_add_par? && users.count < users_per_daily_team
      true
    else
      false
    end
  end

  def scorecard_api(scorecard:)
    handicap_allowance = handicap_computer.handicap_allowance(user: scorecard.golf_outing.user)

    Scorecards::Api::ScorecardAPIBestBall.new(scorecard.tournament_day, scorecard, handicap_allowance).scorecard_representation
  end
end
