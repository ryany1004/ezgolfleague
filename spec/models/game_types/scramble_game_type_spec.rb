require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Scramble" do
  # let(:user) { FactoryBot.create(:user, first_name: "Scramble", last_name: "1") }
  # let(:user_2) { FactoryBot.create(:user, first_name: "Scramble", last_name: "2", email: "user2@domain.com") }
  # let(:league) { FactoryBot.create(:league) }
  # let(:league_membership) { FactoryBot.create(:league_membership, league: league, user: user) }
  # let(:course) { FactoryBot.create(:course_with_holes) }
  # let(:tournament) { FactoryBot.create(:tournament, league: league, name: "Hunter Scramble") }
  # let(:tournament_day) { FactoryBot.create(:tournament_day, tournament: tournament, course: course, game_type_id: 7) }
  # let(:tournament_group) { FactoryBot.create(:tournament_group, tournament_day: tournament_day) }
  # let(:team) { FactoryBot.create(:golfer_team, tournament_day: tournament_day, tournament_group: tournament_group) }

  # it "scramble scoring" do
  #   user_1_scores = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10]
  #   user_2_scores = [1,2,4,1,6,7,8,6,4,7,6,5,3,6,6,5,3,10]

  #   team.users << user
  #   team.users << user_2

  #   tournament_day.add_player_to_group(tournament_group, user)
  #   tournament_day.add_player_to_group(tournament_group, user_2)

  #   add_to_group_and_create_scores(tournament_day, user, tournament_group, user_1_scores)
  #   add_to_group_and_create_scores(tournament_day, user_2, tournament_group, user_2_scores)

  #   scorecard = tournament_day.primary_scorecard_for_user(user)
  #   user_1_scores.each_with_index do |s, i|
  #     course_hole = course.course_holes[i]

  #     metadata = GameTypeMetadatum.find_or_create_by(golfer_team: team, course_hole: course_hole, search_key: "scramble_scorecard_for_best_ball_hole")
  #     metadata.scorecard = scorecard
  #     metadata.save
  #   end

  #   expect(tournament_group.golfer_teams.first.users).to include(user)
  #   expect(tournament_group.golfer_teams.first.users).to include(user_2)

  #   expect(tournament_day.player_score(user)).to eq(88)
  #   expect(tournament_day.player_score(user_2)).to eq(88)
  # end

  let(:generic_scramble) { build(:scramble_game_type) }

  it "#display_name" do
    expect(generic_scramble.display_name).to eq("Scramble")
  end

  it "#game_type_id" do
    expect(generic_scramble.game_type_id).to eq(6)
  end

  it "#show_other_scorecards?"

  it "#allow_teams" do
    expect(generic_scramble.allow_teams).to eq(GameTypes::TEAMS_REQUIRED)
  end

  it "#other_group_members"

  it "#user_is_in_group?"

  it "#setup_partial"

  it "#override_scorecard_name_for_scorecard"

  it "#course_handicap_for_game_type"

  it "#can_be_played?"

  it "#individual_team_scorecards_for_scorecard"

  it "#related_scorecards_for_user"

  it "#assign_payouts_from_scores"

  it "#compute_player_score"
end
