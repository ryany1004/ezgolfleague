FactoryBot.define do
  factory :tournament_day do
    tournament_at { DateTime.now }
    association :course, factory: :course_with_eighteen_holes

    factory :tournament_day_with_flights do 
	    after(:create) do |day|
	      day.course_holes << CourseHole.all

	      day.flights << create(:flight, tournament_day: day, course_tee_box: day.course.course_tee_boxes.first)
	    end
    end
  end
end
