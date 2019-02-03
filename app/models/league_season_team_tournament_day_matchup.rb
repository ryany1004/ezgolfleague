class LeagueSeasonTeamTournamentDayMatchup < ApplicationRecord
	belongs_to :tournament_group
	belongs_to :team_a, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_a_id', optional: true
	belongs_to :team_b, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_b_id', optional: true
end