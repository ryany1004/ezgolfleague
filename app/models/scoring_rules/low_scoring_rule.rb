class LowScoringRule < ScoringRule
	include ::GenericScorecardSupport
	
	def name
		"Low"
	end

	def use_net_score
		true
	end

	def description
		"Low score wins."
	end

	def scoring_computer
		ScoringComputer::LowScoringComputer.new(self)
	end

	def payout_type
		ScoringRulePayoutType::POT
	end

	def calculate_each_entry?
		false
	end

	def optional_by_default
		true
	end

	# TODO: Move these to the base class somehow? Seems lame to have to define as nil if they are simply not supported
	def setup_partial
		nil
	end

	def remove_game_type_options
	end
end