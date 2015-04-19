class CourseHoleTeeBox < ActiveRecord::Base
  belongs_to :course_hole, inverse_of: :course_hole_tee_boxes
  belongs_to :course_tee_box, inverse_of: :course_hole_tee_boxes
  
  validates :yardage, presence: true
end
