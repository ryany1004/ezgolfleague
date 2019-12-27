class MatchPlayScoringRule < StrokePlayScoringRule
	include ::MatchPlayScorecardSupport
	
	def name
		"Match Play"
	end

	def description
		"Player gets a point for each hole they win. Payouts are allotted by most holes won."
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
		ScoringRules::HandicapComputer::MatchPlayHandicapComputer.new(self)
	end

	def scoring_computer
		ScoringComputer::MatchPlayScoringComputer.new(self)
	end

	def flight_based_payouts?
		false
	end

  def includes_extra_scoring_column?
    true
  end

	def results_description_column_name
		"Details"
	end

  def setup_component_name
    nil
  end

	def can_be_played?
	  return false if self.tournament_day.tournament_groups.count.zero?
	  return false if self.tournament_day.scorecard_base_scoring_rule.blank?

	  true
	end

	def can_be_finalized?
		return false if !self.tournament_day.has_scores?
		return false if self.users.count.zero? && self.payout_assignment_type != ScoringRulePayoutAssignmentType::MANUAL

		true
	end

	def finalization_blockers
		blockers = []

		blockers << "#{self.name}: This tournament day has no scores." if !self.tournament_day.has_scores?
		blockers << "#{self.name}: There are no users for this game type." if self.users.count.zero? && self.payout_assignment_type != ScoringRulePayoutAssignmentType::MANUAL

		blockers
	end

  def match_play_scorecard_for_user(user)
    scorecard = ScoringRuleScorecards::MatchPlayScorecard.new
    scorecard.user = user
    scorecard.opponent = self.opponent_for_user(user)
    scorecard.scoring_rule = self
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