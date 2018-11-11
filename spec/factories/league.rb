FactoryBot.define do
  factory :league do
    name { "Brunswick" }
    location { "California" }

    after(:create) do |league|
      league.league_seasons << create(:league_season, league: league)
    end
  end

  factory :league_season do
    starts_at { DateTime.now.beginning_of_year }
    ends_at { DateTime.now.end_of_year }
    name { "Brunswick Season" }
    dues_amount { 50.0 }
    league
  end

  factory :league_membership

  factory :league_season_scoring_group
end
