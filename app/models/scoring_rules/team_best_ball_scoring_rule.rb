class TeamBestBallScoringRule < BestBallScoringRule
  def name
    'Team Best Ball'
  end

  def description
    'The best ball on each hole for each team is used for scoring.'
  end

  def team_type
    ScoringRuleTeamType::LEAGUE
  end

  def users_per_daily_team
    0
  end

  def scoring_computer
    @scoring_computer ||= ScoringComputer::TeamBestBallScoringComputer.new(self)
  end

  def opponent_for_user(user)
    tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
      matchup.pairings_by_handicap.each do |pairing|
        next unless pairing.include? user

        pairing.each do |u|
          return u if u != user # return the other person
        end
      end
    end

    nil
  end

  def best_ball_scorecard_for_team(league_season_team)
    scorecard = ScoringRuleScorecards::BestBallScorecard.new
    scorecard.scoring_rule = self
    scorecard.user = league_season_team.users.first
    scorecard.team = league_season_team
    scorecard.users_to_compare = league_season_team.users
    scorecard.should_use_handicap = true
    scorecard.calculate_scores

    scorecard
  end
end
