module MatchPlayScorecardSupport
	def related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    team = self.tournament_day.daily_team_for_player(user)
    if team.present?
      if !only_human_scorecards
        user_match_play_card = self.match_play_scorecard_for_user_in_team(user, team)
        other_scorecards << user_match_play_card
      end

      team.users.each do |u|
        if u != user
          other_scorecards << self.tournament_day.primary_scorecard_for_user(u)

          if !only_human_scorecards
            other_user_match_play_card = self.match_play_scorecard_for_user_in_team(u, team)
            other_scorecards << other_user_match_play_card
          end
        end
      end
    end

    other_scorecards
	end
end