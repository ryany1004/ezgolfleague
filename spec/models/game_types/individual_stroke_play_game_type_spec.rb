require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Individual Stroke Play" do
  let(:generic_stroke_play) { build(:individual_stroke_play_game_type) }

  it "#display_name" do
    expect(generic_stroke_play.display_name).to eq("Individual Stroke Play")
  end

  it "#other_group_members"

  it "#user_is_in_group?"

  it "#setup_partial" do
    expect(generic_stroke_play.setup_partial).to eq("shared/game_type_setup/individual_stroke_play")
  end

  it "#can_be_played?" do
    tournament = create_stroke_play_tournament(strokes: [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10])

    expect(tournament.first_day.can_be_played?).to eq(true)
  end

  it "#related_scorecards_for_user" do
    tournament = create_two_person_stroke_play_tournament
    golfer = tournament.players.first

    expect(tournament.first_day.scoring_rules.first.related_scorecards_for_user(golfer).count).to eq(1)
  end

  it "verify_results" do
    tournament = create_stroke_play_tournament(strokes: [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10])
    result = tournament.first_day.scoring_rules.first.tournament_day_results.first

    expect(result.gross_score).to eq(88)
    expect(result.net_score).to eq(76)
    expect(result.back_nine_net_score).to eq(45)
    expect(result.front_nine_net_score).to eq(31)
    expect(result.front_nine_gross_score).to eq(37)
    expect(result.par_related_net_score).to eq(5)
    expect(result.par_related_gross_score).to eq(17)
    expect(result.adjusted_score).to eq(85)
  end
end