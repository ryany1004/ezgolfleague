class GrossLowScoringRule < LowScoringRule	
	def name
		"Gross Low"
	end

	def description
		"This contest is automatically calculated by the system. This contest takes the lowest gross score as the winner."
	end

	def use_net_score
		false
	end
end