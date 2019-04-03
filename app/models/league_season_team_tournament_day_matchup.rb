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

		team_a_result = self.tournament_day.scorecard_base_scoring_rule.aggregate_tournament_day_results.where(league_season_team: self.team_a).first
		r << team_a_result if team_a_result.present?

		team_b_result = self.tournament_day.scorecard_base_scoring_rule.aggregate_tournament_day_results.where(league_season_team: self.team_b).first
		r << team_b_result if team_b_result.present?

		r
	end

	def teams_are_balanced?
		self.team_a.users.size == self.team_b.users.size
	end

	def pairings_by_handicap
		raise "Unbalanced teams" if !self.teams_are_balanced?

		pairings = []

		self.team_a_users.each_with_index do |u, i|
			user_b = self.team_b_users[i]

			pairings << [u, user_b]
		end

		pairings
	end

	def users_with_matchup_indicator(team)
		matchups = []

		if team == self.team_a
			users = self.team_a_users
		else
			users = self.team_b_users
		end

		users.each_with_index do |u, i|
			matchups << { user: u, matchup_indicator: self.position_indicator_for_index(i) }
		end

		matchups
	end

	def matchup_indicator_for_user(user)
		if self.team_a.users.include? user
			users = self.team_a.users
		else
			users = self.team_b.users
		end

		users.each_with_index do |u, i|
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

	def user_ids_to_omit
		split_ids = self.excluded_user_ids&.split(",")
		if split_ids.present?
			split_ids
		else
			[]
		end
	end

	def team_a_users
		self.team_a.present? ? self.build_excluded_user_filter(self.team_a.users) : []
	end

	def team_b_users
		self.team_b.present? ? self.build_excluded_user_filter(self.team_b.users) : []
	end

	def build_excluded_user_filter(relation)
		if self.user_ids_to_omit.present?
			relation = relation.where("users.ID NOT IN (?)", self.user_ids_to_omit)
		else
			relation
		end
	end

	def all_users
		self.team_a_users + self.team_b_users
	end

	def toggle_user(user)
		if self.all_users.include?(user)
			self.exclude_user(user)

      group = self.tournament_day.tournament_group_for_player(user)
      self.tournament_day.remove_player_from_group(tournament_group: group, user: user) if group.present?
		else
			self.include_user(user)

    	group = self.tournament_day.tournament_group_with_open_slots(1)
    	raise "No groups available" if group.blank?
    	self.tournament_day.add_player_to_group(tournament_group: group, user: user)
		end
	end

	def exclude_user(user)
		user_ids = self.user_ids_to_omit
		user_ids << user.id unless user_ids.include? user.id

		self.excluded_user_ids = user_ids.join(",")
		self.save
	end

	def include_user(user)
		user_ids = self.user_ids_to_omit
		user_ids.delete(user.id.to_s)

		self.excluded_user_ids = user_ids.join(",")
		self.save
	end
end