require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Scramble" do
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
