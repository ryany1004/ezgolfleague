class Course < ActiveRecord::Base
  has_many :course_holes, -> { order(:hole_number) }, :dependent => :destroy, inverse_of: :course
  has_many :tournaments, :dependent => :destroy, inverse_of: :course
  
  validates :name, presence: true
  
  paginates_per 50
end
