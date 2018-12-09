module StablefordScorecardSupport
	def related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    other_scorecards << self.stableford_scorecard_for_user(user: user) if only_human_scorecards == false

    self.other_group_members(user: user).each do |player|
      other_scorecards << self.tournament_day.primary_scorecard_for_user(player)
      other_scorecards << self.stableford_scorecard_for_user(user: player) if only_human_scorecards == false
    end

    return other_scorecards
	end
end