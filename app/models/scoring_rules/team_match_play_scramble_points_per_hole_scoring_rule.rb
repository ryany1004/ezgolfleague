class TeamMatchPlayScramblePointsPerHoleScoringRule < TeamMatchPlayVsScoringRule
  include ::TeamScrambleScoringRuleSetup

  def name
    'Team Match Play Scramble Points Per Hole'
  end

  def description
    'Team match play in a scramble format where players compete hole-by-hole. Based on net scores, two points are awarded for a win, 1 each for a tie and 0 for a loss.'
  end

  def scoring_computer
    ScoringComputer::TeamMatchPlayScramblePointsPerHoleScoringComputer.new(self)
  end

  def handicap_computer
    ScoringRules::HandicapComputer::TeamMatchPlayScramblePointsPerHoleHandicapComputer.new(self)
  end

  def payout_type
    ScoringRulePayoutType::POT
  end

  def match_play_scorecard_for_user(user)
    scorecard = ScoringRuleScorecards::TeamMatchPlayPointsPerHoleScorecard.new
    scorecard.user = user
    scorecard.opponent = opponent_for_user(user)
    scorecard.scoring_rule = self
    scorecard.calculate_scores

    scorecard
  end

  def other_group_members(user:)
    other_members = []

    matchup = tournament_day.league_season_team_matchup_for_player(user)
    matchup.team_users_for_user(user).each do |u|
      other_members << u if u != user
    end

    other_members
  end

  def override_scorecard_name(scorecard:)
    player_names = scorecard.golf_outing.user.last_name + '/'

    other_members = other_group_members(user: scorecard.golf_outing.user)
    other_members.each do |player|
      player_names << player.last_name

      player_names << '/' if player != other_members.last
    end

    "#{player_names} Scramble"
  end

  def finalize
    # override to do nothing
  end
end
