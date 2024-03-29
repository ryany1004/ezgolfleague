class ScrambleScoringRule < StrokePlayScoringRule
  include ::ScrambleScoringRuleSetup
  include ::ScrambleScorecardSupport

  def name
    'Scramble'
  end

  def description
    'Each player hits a tee shot on each hole, but everyone plays from the spot of the best shot.'
  end

  def team_type
    ScoringRuleTeamType::DAILY
  end

  def scoring_computer
    ScoringComputer::ScrambleScoringComputer.new(self)
  end

  def handicap_computer
    HandicapComputers::ScrambleHandicapComputer.new(self)
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

  def individual_team_scorecards_for_scorecard(scorecard:)
    scorecards = [scorecard]

    other_members = other_group_members(user: scorecard.golf_outing.user)
    other_members.each do |player|
      other_scorecard = tournament_day.primary_scorecard_for_user(player)

      scorecards << other_scorecard
    end

    scorecards
  end
end
