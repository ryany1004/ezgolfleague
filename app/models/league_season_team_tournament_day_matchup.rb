class LeagueSeasonTeamTournamentDayMatchup < ApplicationRecord
	belongs_to :tournament_day
	belongs_to :team_a, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_a_id', optional: true
	belongs_to :team_b, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_b_id', optional: true
	belongs_to :winning_team, class_name: 'LeagueSeasonTeam', foreign_key: 'league_team_winner_id', optional: true

	def teams
		t = []

		t << self.team_a if self.team_a.present?
		t << self.team_b if self.team_b.present?

		t
	end
end