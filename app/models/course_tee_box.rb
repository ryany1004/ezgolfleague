class CourseTeeBox < ActiveRecord::Base
  has_many :course_hole_tee_boxes, inverse_of: :course_tee_box
  belongs_to :course, inverse_of: :course_tee_boxes
  
  validates :name, presence: true
  validates :rating, presence: true
  validates :slope, presence: true
  
end