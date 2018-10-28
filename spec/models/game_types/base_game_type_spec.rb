require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Base Game Type" do
	let(:generic_game_type) { build(:game_type) }

	it "#can_be_finalized?"

	it "#can_be_played?" do
		expect(generic_game_type.can_be_played?).to eq(false)
	end

	it "#show_other_scorecards?" do
		expect(generic_game_type.show_other_scorecards?).to eq(false)
	end

	it "#setup_partial" do 
		expect(generic_game_type.setup_partial).to eq(nil)
	end

	it "#leaderboard_partial_name" do 
		expect(generic_game_type.leaderboard_partial_name).to eq('standard_leaderboard')
	end

	it "#other_group_members" do
		expect(generic_game_type.other_group_members(nil)).to eq(nil)
	end

	it "#user_is_in_group?" do
		expect(generic_game_type.user_is_in_group?(nil, nil)).to eq(false)
	end

	it "#allow_teams" do
		expect(generic_game_type.allow_teams).to eq(GameTypes::TEAMS_DISALLOWED)
	end

	it "#show_teams?" do
		expect(generic_game_type.show_teams?).to eq(false)
	end

	it "#number_of_players_per_team" do
		expect(generic_game_type.number_of_players_per_team).to eq(0)
	end

	it "#players_create_teams?" do
		expect(generic_game_type.players_create_teams?).to eq(true)
	end

	it "#show_team_scores_for_all_teammates?" do
		expect(generic_game_type.show_team_scores_for_all_teammates?).to eq(true)
	end

	it "#team_players_are_opponents?" do
		expect(generic_game_type.team_players_are_opponents?).to eq(false)
	end

	it "#related_scorecards_for_user" do
		expect(generic_game_type.related_scorecards_for_user(nil)).to eq([])
	end

	it "#player_score"

	it "#compute_stroke_play_player_score"

	it "#net_scores_for_scorecard"

	it "#compute_player_score"

	it "#score_or_maximum_for_hole"

	it "#player_points"

	it "#player_payouts"

	it "#includes_extra_scoring_column?" do
		expect(generic_game_type.includes_extra_scoring_column?).to eq(false)
	end

	it "#override_scorecard_name_for_scorecard" do
		expect(generic_game_type.override_scorecard_name_for_scorecard).to eq(nil)
	end

	it "#scorecard_score_cell_partial" do
		expect(generic_game_type.scorecard_score_cell_partial).to eq(nil)
	end

	it "#scorecard_post_embed_partial" do
		expect(generic_game_type.scorecard_post_embed_partial).to eq(nil)
	end

	it "#associated_text_for_score" do
		expect(generic_game_type.associated_text_for_score(nil)).to eq(nil)
	end

	it "#scorecard_payload_for_scorecard"

	it "#course_handicap_for_game_type"

	it "#handicap_allowance"

	it "#players_for_flight"

	it "#flights_with_rankings"

	it "#eligible_players_for_payouts"

	it "#assign_payouts_from_scores"
end
