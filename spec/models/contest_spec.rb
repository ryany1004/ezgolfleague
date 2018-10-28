require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Contest" do
  # let(:user) { FactoryBot.create(:user) }
  # let(:league) { FactoryBot.create(:league) }
  # let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  # let(:course) { FactoryBot.create(:course_with_holes) }
  # let(:tournament) { FactoryBot.create(:tournament, league: league) }
  # let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course) }
  # let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }

  # it "net + gross skins scores correctly" do
  #   add_to_group_and_create_scores(tournament_day, user, tournament_group)

  #   contest = FactoryBot.create(:contest, tournament_day: tournament_day, contest_type: 8)

  #   contest.add_user(user)
  #   contest.score_contest
  #   contest.reload

  #   results = contest.combined_contest_results
  #   results_users = results.map(&:winner)

  #   expect(results_users).to include(user)
  # end

  # it "overall contest winner"

  # it "manual contest override" do
  #   add_to_group_and_create_scores(tournament_day, user, tournament_group)

  #   contest = FactoryBot.create(:contest, tournament_day: tournament_day, contest_type: 4, overall_winner_payout_amount: 100, overall_winner_points: 10)

  #   contest.add_user(user)
  #   contest.score_contest
  #   contest.reload

  #   result = contest.combined_contest_results.first

  #   expect(result).not_to be_nil
  #   expect(result.payout_amount).to eq(100)
  #   expect(result.points).to eq(10)
  # end

  # it "Add user to a contest" do
  #   add_to_group_and_create_scores(tournament_day, user, tournament_group)

  #   contest = FactoryBot.create(:contest, tournament_day: tournament_day, contest_type: 8)

  #   contest.add_user(user)

  #   expect(contest.users).to include(user)
  # end

  let(:generic_user) { create(:user) }

  it "#server_id" do 
    expect(generic_user).to respond_to(:server_id) 
  end

  it "#human_type" do
    overall_winner = create(:contest, contest_type: 0)
    net_skins_gross_skins = create(:contest, contest_type: 8)

    expect(overall_winner.human_type).to eq("Custom: Overall Winner")
    expect(net_skins_gross_skins.human_type).to eq("Net Skins + Gross Skins")
  end

  it "#name_with_cost"

  it "#is_team_scored?"

  it "manual_results_entry?"

  it "allows_overall_winner_points_and_payouts?"

  it "combined_contest_results"

  it "remove_results"

  it "is_by_hole?"

  it "should_sum_winners?"

  it "can_accept_more_results?"

  it "winners"

  it "add_user"

  it "add_winner"

  it "remove_winner"

  it "remove_user"

  it "users_not_signed_up"
end
