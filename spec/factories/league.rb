FactoryBot.define do
  factory :league do
    name "Brunswick"
  end

  factory :league_season do
    starts_at { DateTime.today.start_of_year }
    ends_at { DateTime.today.end_of_year }
    name "Brunswick Season"
    dues_amount 50.0
    league
  end

  factory :league_membership
end
