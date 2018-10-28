FactoryBot.define do
  factory :game_type, class: GameTypes::GameTypeBase do
  end

	factory :individual_stroke_play_game_type, class: GameTypes::IndividualStrokePlay do
	end

	factory :best_ball_game_type, class: GameTypes::BestBall do
	end

	factory :scramble_game_type, class: GameTypes::Scramble do
	end
end
