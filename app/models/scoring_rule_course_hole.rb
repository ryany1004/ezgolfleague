class ScoringRuleCourseHole < ApplicationRecord
	belongs_to :scoring_rule, inverse_of: :scoring_rule_course_holes, counter_cache: true
	belongs_to :course_hole, inverse_of: :scoring_rule_course_holes
	has_many :payout_results, dependent: :destroy

	validates :scoring_rule, presence: true
  validates :course_hole, presence: true
end
