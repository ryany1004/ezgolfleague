class NetLowScoringRule < LowScoringRule
	def name
		"Net Low"
	end

	def description
		"This contest is automatically calculated by the system. This contest takes the lowest net score as the winner."
	end

	def use_net_score
		true
	end
end