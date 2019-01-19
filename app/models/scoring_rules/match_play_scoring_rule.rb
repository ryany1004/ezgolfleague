class MatchPlayScoringRule < ScoringRule
	include ::GenericScorecardSupport
	
	def name
		"Match Play"
	end

	def legacy_game_type_id
		2
	end

  def includes_extra_scoring_column?
    return false
  end
end