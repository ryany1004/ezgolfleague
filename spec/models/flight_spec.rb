require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Flight" do
  let(:user) { FactoryBot.create(:user) }
  let(:league) { FactoryBot.create(:league) }
  let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryBot.create(:course_with_holes) }
  let(:tournament) { FactoryBot.create(:tournament, league: league) }
  let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }

  it "player is flighted correctly" do
    add_to_group_and_create_scores(tournament_day, user, tournament_group)

    flight = tournament_day.flights.first

    expect(flight.users).to include(user)
  end

  it "team is flighted correctly" do
    team_tournament_day = FactoryBot.create(:tournament_day, tournament: tournament, course: course, game_type_id: 10)
    team_tournament_group = FactoryBot.create(:tournament_group, tournament_day: team_tournament_day)

    good_golfer = FactoryBot.create(:user, email: "test@test.com", handicap_index: 2)
    bad_golfer = FactoryBot.create(:user, email: "test2@test.com", handicap_index: 20)

    team_tournament_day.flights.destroy_all

    first_flight = FactoryBot.create(:flight, tournament_day: team_tournament_day, course_tee_box: course.course_tee_boxes.first, flight_number: 1, lower_bound: 0, upper_bound: 10)
    second_flight = FactoryBot.create(:flight, tournament_day: team_tournament_day, course_tee_box: course.course_tee_boxes.first, flight_number: 2, lower_bound: 11, upper_bound: 100)

    team = FactoryBot.create(:golfer_team, tournament_day: team_tournament_day, tournament_group: team_tournament_group, users: [good_golfer, bad_golfer])

    add_to_group_and_create_scores(team_tournament_day, good_golfer, team_tournament_group)
    add_to_group_and_create_scores(team_tournament_day, bad_golfer, team_tournament_group)

    expect(second_flight.users).to include(good_golfer)
    expect(second_flight.users).to include(bad_golfer)
  end
end
