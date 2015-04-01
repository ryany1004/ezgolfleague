class CourseHoleTeeBox < ActiveRecord::Base
  belongs_to :course_hole, inverse_of: :course_hole_tee_boxes
  
  # validates :name, presence: true
  # validates :yardage, presence: true
end
