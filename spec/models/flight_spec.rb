require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Flight" do
  let(:user) { create(:user) }
  let(:league) { create(:league) }
  let(:tournament) { create(:tournament, league: league) }
  let(:tournament_day) { create(:tournament_day, tournament: tournament) }
  let(:tournament_group) { create(:tournament_group, tournament_day: tournament_day) }
  let(:generic_flight) { create(:flight, tournament_day: tournament_day) }

  it "#display_name" do
    league_season_scoring_group = create(:league_season_scoring_group, name: "Super")
    flight_with_scoring_group = create(:flight, tournament_day: tournament_day, league_season_scoring_group: league_season_scoring_group)

    expect(generic_flight.display_name).to eq("1")
    expect(generic_flight.display_name(true)).to eq("Flight 1")
    expect(flight_with_scoring_group.display_name).to eq("Super")
  end

  it "can flight a player" do
    tournament_day.add_player_to_group(tournament_group, user)
    flight = tournament_day.flights.first

    expect(tournament_group.players_signed_up).to include(user)
    expect(flight.users).to include(user)
  end
end
