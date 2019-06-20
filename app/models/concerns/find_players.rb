module FindPlayers
  extend ActiveSupport::Concern

  def flight_for_player(user)
    flights.joins(:users).find_by(users: { id: user.id })
  end

  def daily_team_for_player(user)
    daily_teams.each do |t|
      return t if t.users.include? user
    end

    nil
  end

  def league_season_team_for_player(user)
    league_season_team_tournament_day_matchups.each do |m|
      return m.team_a if m.team_a.present? && m.team_a.users.include?(user)
      return m.team_b if m.team_b.present? && m.team_b.users.include?(user)
    end

    nil
  end

  def league_season_team_matchup_for_player(user)
    league_season_team_tournament_day_matchups.each do |m|
      m.teams.each do |t|
        t.users.each do |u|
          return m if u == user
        end
      end
    end

    nil
  end

  def tournament_group_for_player(user)
    tournament_groups.joins(golf_outings: :user).find_by(golf_outings: { user: user })
  end

  def other_tournament_group_members(user)
    other_members = []

    group = tournament_group_for_player(user)
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
    GolfOuting.joins(:tournament_group).find_by(user: user, tournament_group: tournament_groups.pluck(:id))
  end

  def league_season_team_matchup_for_team(team)
    league_season_team_tournament_day_matchups.find_by('league_season_team_a_id = ? OR league_season_team_b_id = ?', team, team)
  end

  def player_is_confirmed?(user)
    outing = golf_outing_for_player(user)

    if outing.blank?
      false
    else
      outing.is_confirmed
    end
  end

  def scoring_rules_for_user(user:)
    scoring_rules = []

    self.tournament.scoring_rules.each do |r|
      scoring_rules << r if r.users.include? user
    end

    scoring_rules
  end

  def optional_scoring_rules_for_user(user:)
    scoring_rules = []

    tournament.optional_scoring_rules.each do |r|
      scoring_rules << r if r.users.include? user
    end

    scoring_rules
  end
end
