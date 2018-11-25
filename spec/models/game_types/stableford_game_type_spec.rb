require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Stableford" do
  let(:generic_stableford) { build(:stableford_game_type) }

  it "#display_name" do
    expect(generic_stableford.display_name).to eq("Individual Modified Stableford")
  end

  it "#game_type_id" do
    expect(generic_stableford.game_type_id).to eq(3)
  end

  it "#show_other_scorecards?"

  it "#allow_teams" do
    expect(generic_stableford.allow_teams).to eq(GameTypes::TEAMS_DISALLOWED)
  end

  it "#other_group_members"

  it "#user_is_in_group?"

  it "#setup_partial"

  it "#can_be_played?"

  it "#related_scorecards_for_user"

  it "#compute_player_score"

  it "verify_results"

  it "verify_reverse_sorting"
end
