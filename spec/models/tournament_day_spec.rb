require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Tournament Day" do
  let(:user) { FactoryGirl.create(:user) }
  let(:league) { FactoryGirl.create(:league) }
  let(:league_membership) { FactoryGirl.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryGirl.create(:course_with_holes) }
  let(:tournament) { FactoryGirl.create(:tournament, league: league) }
  let(:tournament_day) { FactoryGirl.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryGirl.create(:tournament_group, tournament_day: tournament_day) }

  it "add user to a group" do
    tournament_day.add_player_to_group(tournament_group, user)

    tournament.reload

    expect(tournament.players).to include(user)
    expect(tournament_day.tournament_group_for_player(user)).to eq(tournament_group)
  end

  it "remove user from a group" do
    tournament_day.remove_player_from_group(tournament_group, user)

    expect(tournament.players).not_to include(user)
    expect(tournament_day.tournament_group_for_player(user)).not_to eq(tournament_group)
  end

  it "stroke play scoring" do
    scores = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10]

    add_to_group_and_create_scores(tournament_day, user, tournament_group, scores)

    expect(tournament_day.player_score(user, false)).to eq(scores.sum)
    expect(tournament_day.player_score(user)).to eq(76)
  end

  it "match play scoring"

  it "best ball scoring"

  it "scramble scoring"

  it "shamble scoring"

end
