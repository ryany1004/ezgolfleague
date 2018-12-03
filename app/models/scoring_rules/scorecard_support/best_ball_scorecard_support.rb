module BestBallScorecardSupport
	def related_scorecards_for_user(user, only_human_scorecards = false)
		other_scorecards = []

		team = self.tournament_day.daily_team_for_player(user)
		unless team.blank?
		  team.users.each do |u|
		    if u != user
		      other_scorecards << self.tournament_day.primary_scorecard_for_user(u)
		    end
		  end
		end

		if !only_human_scorecards
		  gross_best_ball_card = self.best_ball_scorecard_for_user_in_team(user, team, false)
		  net_best_ball_card = self.best_ball_scorecard_for_user_in_team(user, team, true)

		  other_scorecards << net_best_ball_card
		  other_scorecards << gross_best_ball_card
		end

		other_scorecards
	end
end