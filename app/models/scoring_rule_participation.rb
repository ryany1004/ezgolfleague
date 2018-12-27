class ScoringRuleParticipation < ApplicationRecord
	belongs_to :scoring_rule, inverse_of: :scoring_rule_participations
	belongs_to :user, inverse_of: :scoring_rule_participations

	validates :scoring_rule, presence: true
  validates :user, presence: true
end
