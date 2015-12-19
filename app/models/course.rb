class Course < ActiveRecord::Base
  include Servable
  
  has_many :course_holes, -> { order(:hole_number) }, :dependent => :destroy, inverse_of: :course
  
  has_many :course_tee_boxes, :dependent => :destroy, inverse_of: :course
  accepts_nested_attributes_for :course_tee_boxes
  
  has_many :tournament_days, :dependent => :destroy, inverse_of: :course
  
  validates :name, presence: true
  
  paginates_per 50

end
