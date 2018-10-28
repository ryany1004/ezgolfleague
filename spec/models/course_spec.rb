require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Course" do
  let(:course_with_eighteen_holes) { create(:course_with_eighteen_holes) }
  let(:course_with_nine_holes) { create(:course_with_nine_holes) }

  it "Checking if a course has 18 holes" do
    expect(course_with_eighteen_holes.course_holes.count).to eq(18)
  end

  it "Checking if a course has 9 holes" do
    expect(course_with_nine_holes.course_holes.count).to eq(9)
  end

  it "#complete_name" do 
  	course = create(:course_with_eighteen_holes, name: "Supercourse", city: "Goleta", us_state: "CA")

  	expect(course.complete_name).to eq("Supercourse - Goleta, CA")
  end

  it "#server_id" do 
  	expect(course_with_eighteen_holes).to respond_to(:server_id) 
  end
end

describe "Course Hole" do
	let(:course_hole) { create(:course_hole, hole_number: 1, par: 4) }
	let(:course_tee_box) { create(:course_tee_box, name: "Men", rating: 71.3, slope: 130) }

	it "#name" do
		expect(course_hole.name).to eq("#1 (Par 4)")
	end

	it "#yardage_strings" do
		hole_tee_box = create(:course_hole_tee_box, course_hole: course_hole, description: "Men", yardage: 400, course_tee_box: course_tee_box)

		expect(course_hole.yardage_strings.count).to eq(1) 
	end

	it "#yards_for_flight" do
		league = create(:league)
		tournament = create(:tournament, league: league)
		tournament_day = create(:tournament_day, tournament: tournament)
		flight = create(:flight, course_tee_box: course_tee_box, tournament_day: tournament_day)
		hole_tee_box = create(:course_hole_tee_box, course_hole: course_hole, description: "Men", yardage: 400, course_tee_box: course_tee_box)

		yards_for_flight = course_hole.yards_for_flight(flight)

		expect(yards_for_flight).to eq(400)
	end
end