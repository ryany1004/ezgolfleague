class SkinsScoringRule < ScoringRule
	def name
		"Skins"
	end

	def use_net_score
		true
	end

	def description
		"A skin is won by a player who posts the lowest score on a hole among all players in the game. The low score must be unique among all scores (no ties). There are potentially 18 skins in an 18 hole match."
	end

	def scoring_computer
		ScoringComputer::SkinsScoringComputer.new(self)
	end
end