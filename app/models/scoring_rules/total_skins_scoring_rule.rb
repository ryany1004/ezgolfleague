class TotalSkinsScoringRule < SkinsScoringRule
	def name
		"Net Skins + Gross Birdies"
	end

	def description
		"This contest is automatically calculated by the system. Same as Net Skins with the addition of all gross birdies also count as a skin."
	end

	def scoring_computer
		ScoringComputer::TotalSkinsScoringComputer.new(self)
	end
end