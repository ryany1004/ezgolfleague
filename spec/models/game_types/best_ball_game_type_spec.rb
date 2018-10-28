require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Best Ball" do
  # let(:user) { FactoryBot.create(:user, first_name: "Best Ball", last_name: "1") }
  # let(:user_2) { FactoryBot.create(:user, first_name: "Best Ball", last_name: "2", email: "user2@domain.com") }
  # let(:league) { FactoryBot.create(:league) }
  # let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  # let(:course) { FactoryBot.create(:course_with_holes) }
  # let(:tournament) { FactoryBot.create(:tournament, league: league, name: "Hunter Best Ball") }
  # let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course, game_type_id: 10) }
  # let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }
  # let(:team) { FactoryBot.create(:golfer_team, tournament_day: tournament_day, tournament_group: tournament_group) }

  # it "best ball scoring" do
  #   user_1_scores = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10]
  #   user_2_scores = [1,2,4,1,6,7,8,6,4,7,6,5,3,6,6,5,3,10]

  #   team.users << user
  #   team.users << user_2

  #   add_to_group_and_create_scores(tournament_day, user, tournament_group, user_1_scores)
  #   add_to_group_and_create_scores(tournament_day, user_2, tournament_group, user_2_scores)

  #   expect(tournament_group.golfer_teams.first.users).to include(user)
  #   expect(tournament_group.golfer_teams.first.users).to include(user_2)

  #   expect(tournament_day.player_score(user)).to eq(82)
  #   expect(tournament_day.player_score(user_2)).to eq(82)
  # end

  let(:generic_best_ball) { build(:best_ball_game_type) }

  it "#display_name" do
    expect(generic_best_ball.display_name).to eq("Best Ball")
  end

  it "#game_type_id" do
    expect(generic_best_ball.game_type_id).to eq(9)
  end

  it "#show_other_scorecards?"

  it "#allow_teams" do
    expect(generic_best_ball.allow_teams).to eq(GameTypes::TEAMS_REQUIRED)
  end

  it "#other_group_members"

  it "#user_is_in_group?"

  it "#setup_partial"

  it "#can_be_played?"

  it "#related_scorecards_for_user"

  it "#compute_player_score"

  it "#best_ball_scorecard_for_user_in_team"

end
