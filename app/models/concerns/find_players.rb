module FindPlayers
  extend ActiveSupport::Concern

  def flight_for_player(user)
    self.flights.includes(:users).each do |f|
      return f if f.users.include? user
    end

    nil
  end

  def daily_team_for_player(user)
    self.daily_teams.each do |t|
      return t if t.users.include? user
    end

    nil
  end

  def league_season_team_for_player(user)
  	self.league_season_team_tournament_day_matchups.each do |m|
  		return m.team_a if m.team_a.users.include? user
  		return m.team_b if m.team_b.users.include? user
  	end

  	nil
  end

  def league_season_team_matchup_for_player(user)
  	self.league_season_team_tournament_day_matchups.each do |m|
  		m.teams.each do |t|
  			t.users.each do |u|
  				return m if u == user
  			end
  		end
  	end

  	nil
  end

  def tournament_group_for_player(user)
    self.tournament_groups.includes(golf_outings: [:user]).each do |group|
      group.golf_outings.each do |outing|
        return group if outing.user == user
      end
    end

    nil
  end

  def other_tournament_group_members(user)
    other_members = []

    group = self.tournament_group_for_player(user)
    group.golf_outings.each do |outing|
      other_members << outing.user if outing.user != user
    end

    other_members
  end

  def user_is_in_tournament_group?(user, tournament_group)
    tournament_group.golf_outings.each do |outing|
      return true if user == outing.user
    end

    false
  end

  def golf_outing_for_player(user)
    self.tournament_groups.includes(golf_outings: [:user]).each do |group|
      group.golf_outings.each do |outing|
        return outing if outing.user == user
      end
    end

    nil
  end

  def league_season_team_matchup_for_team(team)
		self.league_season_team_tournament_day_matchups.where("league_season_team_a_id = ? OR league_season_team_b_id = ?", team, team).first
  end

  def player_is_confirmed?(user)
    outing = self.golf_outing_for_player(user)

    if outing.blank?
      false
    else
      outing.is_confirmed
    end
  end

  def optional_scoring_rules_for_user(user:)
    scoring_rules = []

    self.tournament.optional_scoring_rules.each do |r|
      scoring_rules << r if r.users.include? user
    end

    scoring_rules
  end
end
