require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Individual Stroke Play" do
  let(:generic_stroke_play) { build(:individual_stroke_play_game_type) }

  it "#display_name" do
    expect(generic_stroke_play.display_name).to eq("Individual Stroke Play")
  end

  it "#game_type_id" do
    expect(generic_stroke_play.game_type_id).to eq(1)
  end

  it "#other_group_members"

  it "#user_is_in_group?"

  it "#setup_partial"

  it "#can_be_played?"

  it "#related_scorecards_for_user"
end
