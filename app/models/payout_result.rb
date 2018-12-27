class PayoutResult < ApplicationRecord
	acts_as_paranoid
	
  belongs_to :payout, inverse_of: :payout_results, optional: true, touch: true
  belongs_to :flight, inverse_of: :payout_results, optional: true, touch: true
  belongs_to :user, inverse_of: :payout_results
  belongs_to :scoring_rule, inverse_of: :payout_results, touch: true
  belongs_to :scoring_rule_course_hole, optional: true

  def display_name
  	if self.flight.present?
  		self.flight.display_name
  	else
  		self.scoring_rule.name
  	end
  end

  def tournament_day_result
  	self.scoring_rule.tournament_day_results.where(user: user).first
  end
end
