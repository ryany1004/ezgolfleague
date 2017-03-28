module Handicapable
  extend ActiveSupport::Concern

  # def course_handicap(selected_course, course_tee_box)
  #   return nil if self.handicap_index.blank? or course_tee_box.blank? #this will fail if the user is not flighted
  #
  #   handicap = (self.handicap_index.to_f * (course_tee_box.slope.to_f / 113.0)).round
  #
  #   Rails.logger.debug { "U: #{self.id} HI: #{self.handicap_index.to_f} Slope: #{course_tee_box.slope.to_f} Course Tee Box: #{course_tee_box.id}" }
  #   Rails.logger.debug { "Handicap: #{handicap}" }
  #
  #   return handicap
  # end

  def course_handicap_for_golf_outing(golf_outing)
    if golf_outing.tournament_group.tournament_day.course_holes.count == 9
      self.nine_hole_handicap(golf_outing.tournament_group.tournament_day.course, golf_outing.course_tee_box)
    else
      self.standard_handicap(golf_outing.tournament_group.tournament_day.course, golf_outing.course_tee_box)
    end
  end

  private

  #http://www.usga.org/handicapFAQ/handicap_answer.asp?FAQidx=4
  def standard_handicap(selected_course, course_tee_box)
    return nil if self.handicap_index.blank? or course_tee_box.blank? #this will fail if the user is not flighted

    handicap = (self.handicap_index.to_f * (course_tee_box.slope.to_f / 113.0)).round

    Rails.logger.debug { "U: #{self.id} HI: #{self.handicap_index.to_f} Slope: #{course_tee_box.slope.to_f} Course Tee Box: #{course_tee_box.id}" }
    Rails.logger.debug { "Handicap: #{handicap}" }

    return handicap
  end

  #http://www.mygolfinstructor.com/instruction/rules-of-golf/tips/calculate-9-hole-handicap-18-hole-handicap/569/
  def nine_hole_handicap(selected_course, course_tee_box)
    return nil if self.handicap_index.blank? or course_tee_box.blank? #this will fail if the user is not flighted

    handicap = ((self.handicap_index.to_f / 2.0) * (course_tee_box.slope.to_f / 113.0)).round

    Rails.logger.debug { "U: #{self.id} HI: #{self.handicap_index.to_f} Slope: #{course_tee_box.slope.to_f} Course Tee Box: #{course_tee_box.id}" }
    Rails.logger.debug { "9 Hole Handicap: #{handicap}" }

    return handicap
  end

end
