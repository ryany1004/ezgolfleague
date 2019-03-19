class ManualScoringRule < ScoringRule
	include ::GenericScorecardSupport
	
	def name
		if self.custom_name.present?
			self.custom_name
		else
			"Custom"
		end
	end

	def allows_custom_name?
		true
	end

	def description
		"Manually add a result - good for contests like 'longest drive' or 'closest to the hole'."
	end

	def scoring_computer
		ScoringComputer::ManualScoringComputer.new(self)
	end

	def payout_type
		ScoringRulePayoutType::PREDETERMINED
	end

	def payout_assignment_type
		ScoringRulePayoutAssignmentType::MANUAL
	end

	def can_be_primary?
		false
	end

	def calculate_each_entry?
		false
	end

	def optional_by_default
		true
	end

	def can_be_finalized?
		true
	end

	# TODO: Move these to the base class somehow? Seems lame to have to define as nil if they are simply not supported
	def setup_partial
		nil
	end

	def remove_game_type_options
	end
end