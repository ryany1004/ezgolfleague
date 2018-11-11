module StrokePlayScorecardSupport
	def related_scorecards_for_user(user, only_human_scorecards = false)
	  other_scorecards = []

	  self.tournament_day.other_tournament_group_members(user).each do |player|
	    other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
	  end

	  other_scorecards
	end
end