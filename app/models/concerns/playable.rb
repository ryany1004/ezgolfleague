module Playable
  extend ActiveSupport::Concern

  def display_teams?
    tournament_days.each do |day|
      return true if day.scorecard_base_scoring_rule.team_type == ScoringRuleTeamType::DAILY
    end

    false
  end

  def players(hide_disqualified = false)
    all_group_ids = tournament_days.includes(:tournament_groups).map(&:tournament_groups).flatten.pluck(:id)
    outings = GolfOuting.includes(:user).where(tournament_group: all_group_ids)
    outings = outings.where(disqualified: false) if hide_disqualified
    outings.map(&:user).uniq
  end

  def paid_players
    paid_players = []

    self.players.each do |p|
      paid_players << p if self.user_has_paid?(p)
    end

    paid_players
  end

  def qualified_players
    players(true)
  end

  def players_for_day(day)
    day.tournament_groups.includes(:users).map(&:users).flatten
  end

  def teams_for_day(day)
    teams = []

    day.league_season_team_tournament_day_matchups.each do |matchup|
      teams << matchup.team_a if matchup.team_a.present?
      teams << matchup.team_b if matchup.team_b.present?
    end

    teams
  end

  def number_of_players
    return 0 if first_day.blank?

    number_of_players = 0

    first_day.tournament_groups.each do |group|
      number_of_players = number_of_players + group.players_signed_up.count
    end

    number_of_players
  end

  def includes_player?(user, restrict_to_day = nil)
    player_included = false

    if restrict_to_day.blank?
      days = self.tournament_days
    else
      days = [restrict_to_day]
    end

    days.each do |day|
      day.tournament_groups.each do |group|
        group.players_signed_up.each do |player|
          player_included = true if player == user
        end
      end
    end

    player_included
  end

  def confirm_player(user)
    self.tournament_days.each do |day|
      day.tournament_groups.each do |group|
        group.golf_outings.each do |outing|
          if outing.user == user
            outing.is_confirmed = true
            outing.save
          end
        end
      end
    end
  end

  def total_score(user)
    total_score = 0

    self.tournament_days.each do |day|
      day.displayable_scoring_rules.each do |rule|
        result = rule.result_for_user(user: user)
        total_score += result.net_score unless result.blank?
      end
    end

    total_score
  end

  def total_points(user)
    total_points = 0

    self.tournament_days.each do |day|
      day.displayable_scoring_rules.each do |rule|
        total_points += rule.points_for_user(user: user)
      end
    end

    total_points
  end

end
