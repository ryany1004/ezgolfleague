require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Tournament Day" do
  let(:user) { FactoryBot.create(:user) }
  let(:league) { FactoryBot.create(:league) }
  let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryBot.create(:course_with_holes) }
  let(:tournament) { FactoryBot.create(:tournament, league: league) }
  let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course) }
  let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }

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
end
