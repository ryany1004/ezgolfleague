class LeagueSeasonScoringGroup < ApplicationRecord
	belongs_to :league_season, touch: true

	has_and_belongs_to_many :users, inverse_of: :league_season_scoring_groups
end
