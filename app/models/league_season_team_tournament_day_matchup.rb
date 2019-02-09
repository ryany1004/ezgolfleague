class LeagueSeasonTeamTournamentDayMatchup < ApplicationRecord
	belongs_to :tournament_day
	belongs_to :team_a, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_a_id', optional: true
	belongs_to :team_b, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_b_id', optional: true
	belongs_to :winning_team, class_name: 'LeagueSeasonTeam', foreign_key: 'league_team_winner_id', optional: true

	def name
		combined_name = ""

		self.teams.each do |t|
			combined_name += t.name

			combined_name += " vs. " unless t == self.teams.last
		end

		combined_name
	end

	def teams
		t = []

		t << self.team_a if self.team_a.present?
		t << self.team_b if self.team_b.present?

		t
	end

	def tournament_day_results
		r = []

		team_a_result = self.tournament_day.scorecard_base_scoring_rule.tournament_day_results.where(league_season_team: self.team_a).first
		r << team_a_result if team_a_result.present?

		team_b_result = self.tournament_day.scorecard_base_scoring_rule.tournament_day_results.where(league_season_team: self.team_b).first
		r << team_b_result if team_b_result.present?

		r
	end
end