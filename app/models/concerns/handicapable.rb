module Handicapable
  extend ActiveSupport::Concern
  
  #http://www.usga.org/handicapFAQ/handicap_answer.asp?FAQidx=4
  def course_handicap(selected_course)
    #TODO: this needs to reflect the user's course tee box choice
    return (self.handicap_index * selected_course.course_tee_boxes.first.rating / 113.0).round
  end
  
end