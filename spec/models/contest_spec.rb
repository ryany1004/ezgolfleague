require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Contest" do
  let(:generic_user) { create(:user) }
  let(:league) { create(:league) }
  let(:tournament) { create(:tournament, league: league) }

  it "#server_id" do 
    expect(generic_user).to respond_to(:server_id) 
  end

  it "#human_type" do
    overall_winner = create(:contest, contest_type: 0)
    net_skins_gross_skins = create(:contest, contest_type: 8)

    expect(overall_winner.human_type).to eq("Custom: Overall Winner")
    expect(net_skins_gross_skins.human_type).to eq("Net Skins + Gross Skins")
  end

  it "#name_with_cost" do
    contest = create(:contest, dues_amount: 1)

    expect(contest.name_with_cost).to eq("Contest ($1)")
  end

  it "#is_team_scored?" do
    non_team_contest = create(:contest, contest_type: 1)
    team_contest = create(:contest, contest_type: 2)

    expect(non_team_contest.is_team_scored?).to eq(false)
    expect(team_contest.is_team_scored?).to eq(true)
  end

  it "manual_results_entry?" do
    tournament_day = create(:tournament_day, game_type_id: 10, tournament: tournament)
    team_contest = create(:contest, contest_type: 1, tournament_day: tournament_day)
    expect(team_contest.manual_results_entry?).to eq(true)

    blank_winners = create(:contest, contest_type: 3, tournament_day: tournament_day)
    expect(blank_winners.manual_results_entry?).to eq(false)
  end

  it "allows_overall_winner_points_and_payouts?" do 
    allows_overall = create(:contest, contest_type: 4)
    does_not_allow_overall = create(:contest, contest_type: 8)

    expect(allows_overall.allows_overall_winner_points_and_payouts?).to eq(true)
    expect(does_not_allow_overall.allows_overall_winner_points_and_payouts?).to eq(false)
  end

  it "combined_contest_results"

  it "remove_results"

  it "is_by_hole?" do
    by_hole = create(:contest, contest_type: 1)
    not_by_hole = create(:contest, contest_type: 4)

    expect(by_hole.is_by_hole?).to eq(true)
    expect(not_by_hole.is_by_hole?).to eq(false)
  end
  
  it "winners"

  it "add_user"

  it "add_winner"

  it "remove_winner"

  it "remove_user"

  it "users_not_signed_up"
end
