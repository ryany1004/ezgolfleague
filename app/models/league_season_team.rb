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

	def users_with_matchup_indicator
		matchups = []

		self.users.each_with_index do |u, i|
			matchups << { user: u, matchup_indicator: self.position_indicator_for_index(i) }
		end

		matchups
	end

	def matchup_indicator_for_user(user)
		self.users.each_with_index do |u, i|
			if user == u
				return self.position_indicator_for_index(i)
			end
		end

		return nil
	end

	def position_indicator_for_index(index)
		positions = %w(A B C D E F G H)

		positions[index]
	end
end
