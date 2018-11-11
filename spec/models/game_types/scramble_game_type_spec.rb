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

  it "verify_results" do
    tournament = create_two_person_scramble_tournament(strokes: [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10])
    result = tournament.first_day.tournament_day_results.first

    expect(result.net_score).to eq(63)
    expect(result.gross_score).to eq(88)
    expect(result.back_nine_net_score).to eq(37)
    expect(result.front_nine_net_score).to eq(26)
    expect(result.front_nine_gross_score).to eq(37)
    expect(result.par_related_net_score).to eq(-8)
    expect(result.par_related_gross_score).to eq(17)
    expect(result.adjusted_score).to eq(85)
  end
end
