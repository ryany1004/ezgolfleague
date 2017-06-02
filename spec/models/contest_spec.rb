require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Contest" do
  let(:user) { FactoryGirl.create(:user) }
  let(:league) { FactoryGirl.create(:league) }
  let(:league_membership) { FactoryGirl.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryGirl.create(:course_with_holes) }
  let(:tournament) { FactoryGirl.create(:tournament, league: league) }
  let(:tournament_day) { FactoryGirl.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryGirl.create(:tournament_group, tournament_day: tournament_day) }

  it "net + gross skins scores correctly" do
    add_to_group_and_create_scores(tournament_day, user, tournament_group)

    contest = FactoryGirl.create(:contest, tournament_day: tournament_day, contest_type: 8)

    contest.add_user(user)
    contest.score_contest
    contest.reload

    results = contest.contest_results
    results_users = results.map(&:winner)

    expect(results_users).to include(user)
  end

  if "overall contest winner"

  it "manual contest override" do
    add_to_group_and_create_scores(tournament_day, user, tournament_group)

    contest = FactoryGirl.create(:contest, tournament_day: tournament_day, contest_type: 4, overall_winner_payout_amount: 100, overall_winner_points: 10)

    contest.add_user(user)
    contest.score_contest
    contest.reload

    result = contest.contest_results.first

    expect(result).not_to be_nil
    expect(result.payout_amount).to eq(100)
    expect(result.points).to eq(10)
  end

  it "Add user to a contest" do
    add_to_group_and_create_scores(tournament_day, user, tournament_group)

    contest = FactoryGirl.create(:contest, tournament_day: tournament_day, contest_type: 8)

    contest.add_user(user)

    expect(contest.users).to include(user)
  end

end