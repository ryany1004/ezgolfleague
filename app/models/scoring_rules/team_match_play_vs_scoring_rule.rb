class TeamMatchPlayVsScoringRule < MatchPlayScoringRule
	def name
		"Team Match Play (vs. Opposing Player)"
	end

	def description
		"Team match play where players are matched against a player on another team to compete hole-by-hole."
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
		ScoringComputer::TeamMatchPlayVsScoringComputer.new(self)
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