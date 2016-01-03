class CourseHole < ActiveRecord::Base
  belongs_to :course, inverse_of: :course_holes
  has_and_belongs_to_many :tournament_days
  
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
        yardage_strings << "#{b.course_tee_box.name} - #{b.yardage}" unless b.course_tee_box.blank?
      end
      
      return yardage_strings
    end
  end
  
  def yards_for_flight(flight)
    self.course_hole_tee_boxes.each do |b|
      return b.yardage if b.course_tee_box.name == flight.course_tee_box.name
    end
    
    return nil
  end
  
end
