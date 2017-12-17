require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Golf Outing" do
  let(:user) { FactoryBot.create(:user) }
  let(:league) { FactoryBot.create(:league) }
  let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryBot.create(:course_with_holes) }
  let(:tournament) { FactoryBot.create(:tournament, league: league) }
  let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }

  it "disqualified golfer" do
    add_to_group_and_create_scores(tournament_day, user, tournament_group)

    outing = tournament_day.golf_outing_for_player(user)
    outing.disqualify

    expect(outing.disqualification_description).to eq("Re-Qualify")
  end
end
