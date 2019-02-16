class MatchPlayScoringRule < StrokePlayScoringRule
	include ::MatchPlayScorecardSupport
	
	def name
		"Match Play"
	end

	def description
		"Player gets a point for each hole they win."
	end

	def team_type
		ScoringRuleTeamType::DAILY
	end

	def users_per_daily_team
		2
	end

	def legacy_game_type_id
		2
	end

	def handicap_computer
		HandicapComputer::MatchPlayHandicapComputer.new(self)
	end

  def includes_extra_scoring_column?
    return true
  end

	def setup_partial
		nil
	end

  def match_play_scorecard_for_user_in_team(user, daily_team)
    scorecard = ScoringRuleScorecards::MatchPlayScorecard.new
    scorecard.user = user
    scorecard.opponent = self.opponent_for_user(user)
    scorecard.scoring_rule = self
    scorecard.daily_team = daily_team
    scorecard.calculate_scores

    return scorecard
  end

  def opponent_for_user(user)
    team = self.tournament_day.daily_team_for_player(user)
    unless team.blank?
      team.users.each do |u|
        if u != user
          return u
        end
      end
    end

    return nil
  end
end