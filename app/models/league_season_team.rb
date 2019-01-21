class LeagueSeasonTeam < ApplicationRecord
	belongs_to :league_season
	has_many :league_season_team_memberships
	has_many :users, through: :league_season_team_memberships
end
