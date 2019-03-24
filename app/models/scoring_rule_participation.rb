class ScoringRuleParticipation < ApplicationRecord
	belongs_to :scoring_rule, inverse_of: :scoring_rule_participations
	belongs_to :user, inverse_of: :scoring_rule_participations

	validates :scoring_rule, presence: true
  validates :user, presence: true
  validates :user_id, uniqueness: { scope: :scoring_rule_id } # a user can't be in a given scoring rule twice
end
