FactoryBot.define do
  factory :tournament_group do
    tee_time_at { DateTime.now }
    max_number_of_players { 4 }
  end
end
