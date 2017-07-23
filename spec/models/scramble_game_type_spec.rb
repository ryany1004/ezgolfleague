require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Testing Scramble Game Type" do
  let(:user) { FactoryGirl.create(:user, first_name: "Scramble", last_name: "1") }
  let(:user_2) { FactoryGirl.create(:user, first_name: "Scramble", last_name: "2", email: "user2@domain.com") }
  let(:league) { FactoryGirl.create(:league) }
  let(:league_membership) { FactoryGirl.create(:league_membership, league: league, user: user) }
  let(:course) { FactoryGirl.create(:course_with_holes) }
  let(:tournament) { FactoryGirl.create(:tournament, league: league, name: "Hunter Scramble") }
  let(:tournament_day) { FactoryGirl.create(:tournament_day, tournament: tournament, course: course, game_type_id: 7) }
  let(:tournament_group) { FactoryGirl.create(:tournament_group, tournament_day: tournament_day) }
  let(:team) { FactoryGirl.create(:golfer_team, tournament_day: tournament_day, tournament_group: tournament_group) }

  it "scramble scoring" do
    user_1_scores = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10]
    user_2_scores = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10]

    team.users << user
    team.users << user_2

    tournament_day.add_player_to_group(tournament_group, user)
    tournament_day.add_player_to_group(tournament_group, user_2)

    add_to_group_and_create_scores(tournament_day, user, tournament_group, user_1_scores)
    add_to_group_and_create_scores(tournament_day, user_2, tournament_group, user_2_scores)

    expect(tournament_group.golfer_teams.first.users).to include(user)
    expect(tournament_group.golfer_teams.first.users).to include(user_2)

    expect(tournament_day.player_score(user)).to eq(88)
    expect(tournament_day.player_score(user_2)).to eq(88)
  end
end
