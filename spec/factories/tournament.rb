FactoryBot.define do
  factory :tournament do
    name { "Stroke Play" }
    signup_opens_at { DateTime.now }
    signup_closes_at { DateTime.now + 1.day }
    max_players { 100 }
  end
end
