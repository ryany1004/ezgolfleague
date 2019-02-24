module MatchPlayScorecardSupport
	def related_scorecards_for_user(user, only_human_scorecards = false)
		if self.instance_of?(MatchPlayScoringRule)
			self.daily_team_related_scorecards_for_user(user, only_human_scorecards)
		elsif self.instance_of?(TeamMatchPlayScoringRule)
			self.league_team_related_scorecards_for_user(user, only_human_scorecards)
		else
			[]
		end
	end

	def daily_team_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    team = self.tournament_day.daily_team_for_player(user)
    if team.present?
      if !only_human_scorecards
        user_match_play_card = self.match_play_scorecard_for_user(user)
        other_scorecards << user_match_play_card
      end

      team.users.each do |u|
        if u != user
          other_scorecards << self.tournament_day.primary_scorecard_for_user(u)

          if !only_human_scorecards
            other_user_match_play_card = self.match_play_scorecard_for_user(u)
            other_scorecards << other_user_match_play_card
          end
        end
      end
    end

    other_scorecards
	end

	def league_team_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    if !only_human_scorecards
    	user_match_play_card = self.match_play_scorecard_for_user(user)
    	other_scorecards << user_match_play_card
    end

    opponent = self.opponent_for_user(user)
    if opponent.present?
    	other_scorecards << self.tournament_day.primary_scorecard_for_user(opponent)

	    if !only_human_scorecards
	    	opponent_match_play_card = self.match_play_scorecard_for_user(opponent)
	    	other_scorecards << opponent_match_play_card
	    end
    end

    other_scorecards
	end
end