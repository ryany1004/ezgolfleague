class LeagueSeasonTeam < ApplicationRecord
	belongs_to :league_season
	has_many :league_season_team_memberships
	has_many :users, through: :league_season_team_memberships

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
end
