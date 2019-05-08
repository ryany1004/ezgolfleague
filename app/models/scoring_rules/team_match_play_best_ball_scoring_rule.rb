class TeamMatchPlayBestBallScoringRule < MatchPlayScoringRule
  def name
    'Team Match Play (Best Ball)'
  end

  def description
    'Team match play each hole is determined by the team\'s best ball. Sometimes called Four Ball.'
  end

  def team_type
    ScoringRuleTeamType::LEAGUE
  end

  def users_per_daily_team
    0
  end

  def teams_are_player_vs_player?
    true
  end

  def scoring_computer
    @scoring_computer ||= ScoringComputer::TeamMatchPlayBestBallScoringComputer.new(self)
  end

  def handicap_computer
    HandicapComputer::BaseHandicapComputer.new(self) # this game type does not use match play handicaps
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

  def finalize
    tournament_day.league_season_team_tournament_day_matchups.each(&:save_teams_sort)
  end
end
