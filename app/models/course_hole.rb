class CourseHole < ActiveRecord::Base
  belongs_to :course, inverse_of: :course_holes
  has_and_belongs_to_many :tournaments
  
  has_many :course_hole_tee_boxes, -> { order("yardage desc") }, :dependent => :destroy, inverse_of: :course_hole
  accepts_nested_attributes_for :course_hole_tee_boxes
  
  def name
    return "##{self.hole_number} (Par #{self.par})"
  end
  
  def yardage_strings
    if self.course_hole_tee_boxes.blank?
      return ["N/A"]
    else
      yardage_strings = []
      
      self.course_hole_tee_boxes.each do |b|
        yardage_strings << "#{b.name} - #{b.yardage}"
      end
      
      return yardage_strings
    end
  end
  
end
