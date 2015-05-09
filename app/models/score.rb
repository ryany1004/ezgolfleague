class Score < ActiveRecord::Base
  belongs_to :scorecard, inverse_of: :scores
  belongs_to :course_hole  
end
