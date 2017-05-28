require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Golf Outing" do
  let(:user) { FactoryGirl.create(:user) }
  let(:league) { FactoryGirl.create(:league) }
  let(:league_membership) { FactoryGirl.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryGirl.create(:course_with_holes) }
  let(:tournament) { FactoryGirl.create(:tournament, league: league) }
  let(:tournament_day) { FactoryGirl.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryGirl.create(:tournament_group, tournament_day: tournament_day) }

  it "disqualified golfer" do
    add_to_group_and_create_scores(tournament_day, user, tournament_group)

    outing = tournament_day.golf_outing_for_player(user)
    outing.disqualify

    expect(outing.disqualification_description).to eq("Re-Qualify")
  end
end
