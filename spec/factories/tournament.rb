FactoryGirl.define do
  factory :tournament do
    name "Hunter Classic"

    # factory :course_with_holes do
    #   after(:create) do |course|
    #     create(:course_hole, course: course, hole_number: 1, par: 4, mens_handicap: 5, womens_handicap: 5)
    #     create(:course_hole, course: course, hole_number: 2, par: 3, mens_handicap: 11, womens_handicap: 11)
    #     create(:course_hole, course: course, hole_number: 3, par: 4, mens_handicap: 11, womens_handicap: 11)
    #     create(:course_hole, course: course, hole_number: 4, par: 4, mens_handicap: 1, womens_handicap: 9)
    #     create(:course_hole, course: course, hole_number: 5, par: 5, mens_handicap: 3, womens_handicap: 1)
    #     create(:course_hole, course: course, hole_number: 6, par: 3, mens_handicap: 15, womens_handicap: 15)
    #     create(:course_hole, course: course, hole_number: 7, par: 5, mens_handicap: 9, womens_handicap: 3)
    #     create(:course_hole, course: course, hole_number: 8, par: 4, mens_handicap: 7, womens_handicap: 7)
    #     create(:course_hole, course: course, hole_number: 9, par: 3, mens_handicap: 13, womens_handicap: 13)
    #     create(:course_hole, course: course, hole_number: 10, par: 5, mens_handicap: 2, womens_handicap: 2)
    #     create(:course_hole, course: course, hole_number: 11, par: 3, mens_handicap: 18, womens_handicap: 10)
    #     create(:course_hole, course: course, hole_number: 12, par: 4, mens_handicap: 6, womens_handicap: 18)
    #     create(:course_hole, course: course, hole_number: 13, par: 4, mens_handicap: 10, womens_handicap: 16)
    #     create(:course_hole, course: course, hole_number: 14, par: 5, mens_handicap: 4, womens_handicap: 4)
    #     create(:course_hole, course: course, hole_number: 15, par: 4, mens_handicap: 8, womens_handicap: 8)
    #     create(:course_hole, course: course, hole_number: 16, par: 4, mens_handicap: 16, womens_handicap: 12)
    #     create(:course_hole, course: course, hole_number: 17, par: 3, mens_handicap: 14, womens_handicap: 6)
    #     create(:course_hole, course: course, hole_number: 18, par: 4, mens_handicap: 12, womens_handicap: 14)
    #   end
    # end
  end

  # factory :course_hole
end
