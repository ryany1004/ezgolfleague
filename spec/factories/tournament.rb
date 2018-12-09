FactoryBot.define do
  factory :tournament do
    name { "Tournament" }
    signup_opens_at { DateTime.now }
    signup_closes_at { DateTime.now + 1.day }
    max_players { 100 }

    factory :stroke_play_tournament do
    	name { "Stroke Play" }
    end

    factory :stableford_tournament do
    	name { "Stableford" }
    end
  end
end
