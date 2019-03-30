class LeagueSeasonTeam < ApplicationRecord
	belongs_to :league_season
	has_many :tournament_day_results, inverse_of: :league_season_team
	has_many :league_season_team_memberships
	has_many :users, ->{ order 'handicap_index' }, through: :league_season_team_memberships
	has_many :payout_results, inverse_of: :league_season_team
	has_many :league_season_rankings, dependent: :destroy

	def should_update_team_name?
		self.name.include? "Players: "
	end

	def update_team_name
		self.name = "Players: "

		self.users.each do |u|
			self.name << u.short_name

			if u != self.users.last
				self.name << " / "
			end
		end

		self.save
	end
end
