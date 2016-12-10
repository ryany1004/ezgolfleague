FactoryGirl.define do
  factory :league do
    name "Brunswick"
    dues_amount 50.00
  end

  factory :league_season do
    starts_at { DateTime.today.start_of_year }
    ends_at { DateTime.today.end_of_year }
    name "Brunswick Season"
    league
  end
end
