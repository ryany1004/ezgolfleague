module ScoringComputer
	class DailyTeamScoringComputer < BaseScoringComputer
		def can_be_scored?
			if @scoring_rule.team_type == ScoringRuleTeamType::DAILY
				self.all_daily_team_members_are_included?
			else
				true
			end
		end

		def all_daily_team_members_are_included?
			self.tournament_day.daily_teams.includes(:daily_teams, :users).each do |team|
				team_participation = []

	      if team.users.count > 0 #empty teams do not count
	        team.users.includes(:daily_teams).each do |teammate|
	          if @scoring_rule.users.include? teammate
	            team_participation << true
	          else
	            team_participation << false
	          end
	        end
	      end

	      if team_participation.length > 0 and team_participation.uniq.length != 1 #all yes or all no is fine ; mix is not fine
	        return false
	      end
			end
		end

		true
	end
end