module StrokePlayScorecardSupport
	def related_scorecards_for_user(user, only_human_scorecards = false)
		if self.instance_of?(TeamStrokePlayVsScoringRule)
			self.league_team_vs_scorecards_for_user(user, only_human_scorecards)
		else
			self.group_scorecards_for_user(user, only_human_scorecards)
		end
	end

	def group_scorecards_for_user(user, only_human_scorecards = false)
	  other_scorecards = []

	  self.tournament_day.other_tournament_group_members(user).each do |player|
	    other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
	  end

	  other_scorecards
	end

	def league_team_vs_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    opponent = self.opponent_for_user(user)
    if opponent.present?
    	other_scorecards << self.tournament_day.primary_scorecard_for_user(opponent)
    end

    other_scorecards
	end

  def other_group_members(user:)
    other_members = []

    group = self.tournament_day.tournament_group_for_player(user)
    group&.golf_outings&.each do |outing|
      other_members << outing.user if outing.user != user
    end

    other_members
  end
end