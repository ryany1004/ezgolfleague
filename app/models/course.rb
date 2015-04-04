class Course < ActiveRecord::Base
  has_many :course_holes, -> { order(:hole_number) }, :dependent => :destroy, inverse_of: :course
  has_many :tournaments, :dependent => :destroy, inverse_of: :course
  
  validates :name, presence: true
  
  paginates_per 50
  
  def tee_box_types
    box_types = []
    
    self.course_holes.each do |h|
      h.course_hole_tee_boxes.each do |b|
        box_types << b.name unless box_types.include? b.name
      end
    end
    
    return box_types
  end
  
end
