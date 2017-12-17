require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing ISP Game Type" do
  let(:user) { FactoryBot.create(:user) }
  let(:league) { FactoryBot.create(:league) }
  let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryBot.create(:course_with_holes) }
  let(:tournament) { FactoryBot.create(:tournament, league: league) }
  let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }

  it "stroke play scoring" do
    scores = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10]

    add_to_group_and_create_scores(tournament_day, user, tournament_group, scores)

    expect(tournament_day.player_score(user, false)).to eq(scores.sum)
    expect(tournament_day.player_score(user)).to eq(76)
  end
end
