class LeagueSeasonScoringGroup < ApplicationRecord
	belongs_to :league_season, inverse_of: :league_season_scoring_groups, touch: true
	belongs_to :flight, inverse_of: :league_season_scoring_group

	has_and_belongs_to_many :users, inverse_of: :league_season_scoring_groups
end
