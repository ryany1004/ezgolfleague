class LeagueSeasonTeamMembership < ApplicationRecord
	belongs_to :user
	belongs_to :league_season_team
end
