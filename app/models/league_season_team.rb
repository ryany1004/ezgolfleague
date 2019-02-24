class LeagueSeasonTeam < ApplicationRecord
	belongs_to :league_season
	has_many :tournament_day_results, inverse_of: :league_season_team
	has_many :league_season_team_memberships
	has_many :users, ->{ order 'handicap_index' }, through: :league_season_team_memberships
	has_many :payout_results, inverse_of: :league_season_team
	has_many :league_season_rankings, dependent: :destroy

	def update_team_name
		self.name = ""

		self.users.each do |u|
			self.name << u.short_name

			if u != self.users.last
				self.name << " / "
			end
		end

		self.save
	end

	def name_with_matchup(matchup)
		matchup_name = ""

		positions = %w(A B C D E F)

		self.users.each_with_index do |u, i|
			matchup_name << "#{positions[i]}) " + u.short_name

			if u != self.users.last
				matchup_name << " "
			end
		end

		matchup_name
	end
end
