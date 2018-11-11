FactoryBot.define do
  factory :flight do
    flight_number { 1 }
    lower_bound { 0 }
    upper_bound { 1000 }
    course_tee_box
  end
end
