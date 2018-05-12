class LeagueSeasonScoringGroup < ApplicationRecord
	belongs_to :league_season, touch: true
	belongs_to :flight

	has_and_belongs_to_many :users, inverse_of: :league_season_scoring_groups
end
