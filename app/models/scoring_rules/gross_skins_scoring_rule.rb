class GrossSkinsScoringRule < SkinsScoringRule
	def name
		"Gross Skins"
	end

	def use_net_score
		false
	end
end