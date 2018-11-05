require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Best Ball" do
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
