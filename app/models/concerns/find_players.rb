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
