require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Handicaps" do
  let(:user) { FactoryBot.create(:user) }
  let(:league) { FactoryBot.create(:league) }
  let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryBot.create(:course_with_holes) }
  let(:tournament) { FactoryBot.create(:tournament, league: league) }
  let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }

  it "Verify course handicap for user" do
    scores = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10]

    add_to_group_and_create_scores(tournament_day, user, tournament_group, scores)

    outing = tournament_day.golf_outing_for_player(user)

    expect(outing.course_handicap).to eq(14)
  end

end
