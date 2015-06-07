require 'smarter_csv'

module Importers
  class CourseHolesImporter
  
    def import(filename)
      course_lines = SmarterCSV.process(filename)
      
      Rails.logger.debug { "Number of Lines: #{course_lines.count}" }
      
      course_lines.each do |line|
        Course.transaction do
          course = Course.where(id: line[:course_id]).first
          raise "Missing Course" if course.blank?
        
          course_hole = self.find_or_create_course_hole(course, line[:hole_number], line[:par], line[:mens_handicap], line[:womens_handicap])
          raise "Missing Course Hole" if course_hole.blank?
          
          course_hole_tee_box = self.find_or_create_course_hole_tee_box(course_hole, line[:tee_box_name], line[:yards], line[:tee_box_description_optional])
          raise "Missing Course Hole Tee Box" if course_hole_tee_box.blank?
        end
      end
    end
    
    def find_or_create_course_hole(course, hole_number, par, mens_handicap, womens_handicap)
      course_hole = course.course_holes.where(hole_number: hole_number).first
      if course_hole.blank?
        raise "Missing Required Data" if par.blank?
        
        course_hole = CourseHole.create(course: course, hole_number: hole_number, par: par, mens_handicap: mens_handicap, womens_handicap: womens_handicap)
      end
      
      return course_hole
    end

    def find_or_create_course_hole_tee_box(course_hole, tee_box_name, yards, optional_description)
      course_tee_box = course_hole.course.course_tee_boxes.where(name: tee_box_name).first
      raise "Missing Required Data" if course_tee_box.blank?
      
      course_hole_tee_box = course_hole.course_hole_tee_boxes.where(name: tee_box_name).first
      if course_hole_tee_box.blank?
        course_hole_tee_box = CourseHoleTeeBox.create(course_hole: course_hole, course_tee_box: course_tee_box, yardage: yards, description: optional_description)
      end
      
      return course_hole_tee_box
    end
  
  end
end