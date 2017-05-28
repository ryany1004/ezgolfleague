require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Payouts" do
  it "Verify payouts in the right order" do
    course = FactoryGirl.create(:course_with_holes)
    league = FactoryGirl.create(:league)
    tournament = FactoryGirl.create(:tournament, league: league)
    tournament_day = FactoryGirl.create(:tournament_day, tournament: tournament, course: course)
    tournament_group = FactoryGirl.create(:tournament_group, tournament_day: tournament_day)
    payout = FactoryGirl.create(:payout, flight: tournament_day.flights.first)

    good_golfer = FactoryGirl.create(:user, first_name: "Good", last_name: "Golfer", email: "good@golfer.com", handicap_index: 12)
    bad_golfer = FactoryGirl.create(:user, first_name: "Bad", last_name: "Golfer", email: "bad@golfer.com", handicap_index: 12)

    add_to_group_and_create_scores(tournament_day, bad_golfer, tournament_group, [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10])
    add_to_group_and_create_scores(tournament_day, good_golfer, tournament_group, [1,1,2,4,2,3,5,6,1,7,6,5,3,6,6,5,3,2])

    tournament_day.score_users
    tournament_day.assign_payouts_from_scores
    tournament_day.reload

    expect(tournament_day.payout_results.first.user).to eq(good_golfer)
  end
end
