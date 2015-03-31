class CourseHole < ActiveRecord::Base
  belongs_to :course, inverse_of: :course_holes
  has_many :course_hole_tee_box, -> { order("yardage desc") }, :dependent => :destroy, inverse_of: :course_hole
  
end
