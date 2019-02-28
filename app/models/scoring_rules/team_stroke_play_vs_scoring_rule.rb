class TeamStrokePlayVsScoringRule < StrokePlayScoringRule
	def name
		"Team Stroke Play (vs. Opposing Player)"
	end

	def description
		"Team stroke play where each team member plays an opposing team member."
	end

	def team_type
		ScoringRuleTeamType::LEAGUE
	end

	def teams_are_player_vs_player?
		true
	end

	def flight_based_payouts?
		false
	end

	def can_be_played?
	  return false if self.tournament_day.scorecard_base_scoring_rule.blank?

	  true
	end

	def can_be_finalized?
		return false if self.payouts.size.zero?
		return false if !self.tournament_day.has_scores?
		return false if self.users.count == 0

		true
	end

	def scoring_computer
		ScoringComputer::TeamStrokePlayVsScoringComputer.new(self)
	end

  def opponent_for_user(user)
    self.tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
    	matchup.pairings_by_handicap.each do |pairing|
    		if pairing.include? user
    			pairing.each do |u|
    				return u if u != user # return the other person
    			end
    		end
    	end
  	end

  	return nil
  end
end