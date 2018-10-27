FactoryBot.define do
  factory :tournament_day do
    game_type_id { 1 }
    tournament_at { DateTime.now }
    association :course, factory: :course_with_holes

    after(:create) do |day|
      day.course_holes << CourseHole.all

      day.flights << create(:flight, tournament_day: day, course_tee_box: day.course.course_tee_boxes.first)
    end
  end
end
