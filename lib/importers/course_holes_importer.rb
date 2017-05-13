module Importers
  class TemporaryCourse
    attr_accessor :club_id, :course_id, :club_name, :address, :city, :state, :postal_code, :phone_number, :website_url, :latitude, :longitude
  end

  class TemporaryTeeBox
    attr_accessor :course_id, :name, :color, :par_for_tee, :rating, :slope, :holes
  end

  class TemporaryCourseHole
    attr_accessor :course_id, :tee_box_name, :distance, :par, :handicap, :hole_number
  end

  class CourseHolesImporter

    def import(club_filename, course_filename, holes_filename, import_tag)
      temporary_courses = []
      temporary_tee_boxes = []

      puts "Building Temp Courses"

      CSV.foreach(club_filename, {:headers => true, :header_converters => :symbol}) do |club|
        temp_course = TemporaryCourse.new
        temp_course.club_id = club[:club_id]
        temp_course.club_name = club[:club_name]
        temp_course.address = club[:address]
        temp_course.city = club[:city]

        if Course.where("name = ? AND street_address_1 = ?", temp_course.club_name, temp_course.address).blank?
          US_STATES.each do |state|
            temp_course.state = state.last if state.first == club[:state]
          end

          temp_course.postal_code = club[:postal_code]
          temp_course.phone_number = club[:phone]
          temp_course.website_url = club[:website]
          temp_course.latitude = club[:latitude]
          temp_course.longitude = club[:longitude]

          temporary_courses << temp_course
        else
          puts "Skipping #{temp_course.club_name}."
        end
      end

      puts "Building Temp Clubs"

      CSV.foreach(course_filename, {:headers => true, :header_converters => :symbol}) do |course|
        temporary_courses.each do |tc|
          if tc.club_id == course[:club_id]
            tc.course_id = course[:course_id]

            break
          end
        end
      end

      puts "Building Temp Holes"

      CSV.foreach(holes_filename, {:headers => true, :header_converters => :symbol}) do |hole|
        tee_box = TemporaryTeeBox.new
        tee_box.course_id = hole[:course_id]

        if hole[:tee_name] == hole[:tee_color]
          tee_box.name = hole[:tee_color]
        else
          tee_box.name = "#{hole[:tee_name]} - #{hole[:tee_color]}"
        end

        tee_box.rating = hole[:rating]
        tee_box.slope = hole[:slope]
        tee_box.holes = []

        (1..18).each do |n|
          temp_hole = TemporaryCourseHole.new
          temp_hole.course_id = hole[:course_id]
          temp_hole.hole_number = n.to_s
          temp_hole.distance = hole["hole#{n}".to_sym]
          temp_hole.par = hole["hole#{n}_par".to_sym]
          temp_hole.handicap = hole["hole#{n}_handicap".to_sym]

          tee_box.holes << temp_hole
        end

        temporary_tee_boxes << tee_box
      end

      puts "Courses: #{temporary_courses.count}. Tee Boxes: #{temporary_tee_boxes.count}"

      temporary_courses.each do |tc|
        Course.transaction do
          if Course.where("import_tag IS NULL AND (name = ? OR street_address_1 = ?)", tc.club_name, tc.address).blank?
            puts "Importing #{tc.club_name}"

            c = Course.create(name: tc.club_name, phone_number: tc.phone_number, street_address_1: tc.address, city: tc.city, us_state: tc.state, postal_code: tc.postal_code, latitude: tc.latitude, longitude: tc.longitude, import_tag: import_tag, website_url: tc.website_url)

            temporary_tee_boxes.each do |tb|
              if tb.course_id == tc.course_id
                course_tee_box = CourseTeeBox.create(course: c, name: tb.name, rating: tb.rating, slope: tb.slope)

                tb.holes.each do |th|
                  course_hole = CourseHole.where(course: c, hole_number: th.hole_number).first
                  course_hole = CourseHole.create(course: c, hole_number: th.hole_number, par: th.par, mens_handicap: th.handicap, womens_handicap: th.handicap) if course_hole.blank?

                  course_hole_tee_box = CourseHoleTeeBox.create(course_hole: course_hole, course_tee_box: course_tee_box, yardage: th.distance)
                end
              end
            end
          end
        end
      end
    end
  end
end
