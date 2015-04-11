class Score < ActiveRecord::Base
  belongs_to :scorecard, inverse_of: :scorecards
  has_one :course_hole
end
