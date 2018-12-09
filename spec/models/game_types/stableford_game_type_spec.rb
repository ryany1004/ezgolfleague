require 'rails_helper'

describe "Stableford" do
  let(:generic_stableford) { build(:individual_modified_stableford_scoring_rule) }

  it "#display_name" do
    expect(generic_stableford.name).to eq("Stableford")
  end

  it "#setup_partial" do
    expect(generic_stableford.setup_partial).to eq("shared/game_type_setup/individual_stableford")
  end

  it "#can_be_played?" do
    tournament = create_stableford_tournament(strokes: [1,3,5,1,2,5,1,2,6,1,2,6,1,4,2,4,1,5])

    expect(tournament.first_day.can_be_played?).to eq(true)
  end

  it "verify_results" do
    tournament = create_stableford_tournament(strokes: [1,3,5,1,2,5,1,2,6,1,2,6,1,4,2,4,1,5])
    result = tournament.first_day.scoring_rules.first.tournament_day_results.first

    expect(result.gross_score).to eq(63)
    expect(result.net_score).to eq(57)
    expect(result.back_nine_net_score).to eq(38)
    expect(result.front_nine_net_score).to eq(19)
    expect(result.front_nine_gross_score).to eq(22)
    expect(result.par_related_net_score).to eq(-14)
    expect(result.par_related_gross_score).to eq(-8)
    expect(result.adjusted_score).to eq(52)
  end
end