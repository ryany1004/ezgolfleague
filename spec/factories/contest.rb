FactoryGirl.define do
  factory :contest do
    name "Contest"

    after(:create) do |contest|
      unless contest.tournament_day.blank?
        contest.tournament_day.course_holes.each do |c|
          contest.contest_holes << create(:contest_hole, course_hole: c)
        end
      end
    end
  end

  factory :contest_hole
end
