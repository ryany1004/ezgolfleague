module Handicapable
  extend ActiveSupport::Concern
  
  #http://www.usga.org/handicapFAQ/handicap_answer.asp?FAQidx=4
  def course_handicap(selected_course, course_tee_box)    
    return nil if self.handicap_index.blank? or course_tee_box.blank? #this will fail if the user is not flighted
    
    handicap = (self.handicap_index.to_f * (course_tee_box.slope.to_f / 113.0)).round
    
    Rails.logger.debug { "U: #{self.id} HI: #{self.handicap_index.to_f} Slope: #{course_tee_box.slope.to_f}" }
    Rails.logger.debug { "Handicap: #{handicap}" }

    return handicap
  end
  
end