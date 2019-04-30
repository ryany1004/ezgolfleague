module BestBallScorecardSupport
  def related_scorecards_for_user(user, only_human_scorecards = false)
  	other_scorecards = []

  	team = tournament_day.daily_team_for_player(user)
  	unless team.blank?
  	  team.users.each do |u|
  	    if u != user
          user_scorecard = tournament_day.primary_scorecard_for_user(u)
  	      other_scorecards << user_scorecard if user_scorecard.present?
  	    end
  	  end
  	end

  	if !only_human_scorecards
  	  gross_best_ball_card = best_ball_scorecard_for_user_in_team(user, team, false)
  	  net_best_ball_card = best_ball_scorecard_for_user_in_team(user, team, true)

  	  other_scorecards << net_best_ball_card if net_best_ball_card.present?
  	  other_scorecards << gross_best_ball_card if gross_best_ball_card.present?
  	end

  	other_scorecards
  end
end
