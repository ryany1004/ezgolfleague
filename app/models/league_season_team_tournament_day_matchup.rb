class LeagueSeasonTeamTournamentDayMatchup < ApplicationRecord
  belongs_to :tournament_day
  belongs_to :team_a, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_a_id', optional: true
  belongs_to :team_b, class_name: 'LeagueSeasonTeam', foreign_key: 'league_season_team_b_id', optional: true
  belongs_to :winning_team, class_name: 'LeagueSeasonTeam', foreign_key: 'league_team_winner_id', optional: true

  def name
    combined_name = ''

    teams.each do |t|
      combined_name += t.name
      combined_name += ' vs. ' unless t == teams.last
    end

    combined_name
  end

  def teams
    t = []

    t << team_a if team_a.present?
    t << team_b if team_b.present?

    t
  end

  def tournament_day_results
    r = []

    team_a_result = tournament_day.scorecard_base_scoring_rule.aggregate_tournament_day_results.find_by(league_season_team: team_a)
    r << team_a_result if team_a_result.present?

    team_b_result = tournament_day.scorecard_base_scoring_rule.aggregate_tournament_day_results.find_by(league_season_team: team_b)
    r << team_b_result if team_b_result.present?

    r
  end

  def teams_are_balanced?
    Rails.logger.debug { "teams_are_balanced? #{id} - team_a #{team_a.id} is #{team_a.users.size} & team_b #{team_b.id} is #{team_b.users.size}" }

    team_a_users.size == team_b_users.size
  end

  def pairings_by_handicap
    pairings = []

    base_team_users = team_a_users
    other_team_users = team_b_users

    if team_a_users.count.zero?
      base_team_users = team_b_users
      other_team_users = team_a_users
    end

    base_team_users.each_with_index do |u, i|
      other_user = other_team_users[i]

      if other_user.present?
        pairings << [u, other_user]
      else
        pairings << [u]
      end
    end

    pairings
  end

  def users_with_matchup_indicator(team)
    matchups = []

    users_for_team(team).each_with_index do |u, i|
      matchups << { user: u, matchup_indicator: position_indicator_for_index(i) }
    end

    matchups
  end

  def matchup_indicator_for_user(user)
    team_users_for_user(user).each_with_index do |u, i|
      return position_indicator_for_index(i) if user == u
    end

    nil
  end

  def position_indicator_for_index(index)
    positions = %w[A B C D E F G H I J K]

    positions[index]
  end

  def user_ids_to_omit
    split_ids = excluded_user_ids&.split(',')
    split_ids.presence || []
  end

  def sort_users(users)
    users.sort { |a, b|
      a_scorecard = tournament_day.primary_scorecard_for_user(a)
      b_scorecard = tournament_day.primary_scorecard_for_user(b)

      if a_scorecard.present? && b_scorecard.present?
        a_scorecard.course_handicap <=> b_scorecard.course_handicap
      else
        0
      end
    }
  end

  def filtered_team_a_users
    filtered_users = team_a.present? ? build_excluded_user_filter(team_a.users) : []
    sort_users(filtered_users)
  end

  def team_a_users
    return [] if team_a.blank?

    if team_a_final_sort.present?
      team_a.users.where(id: team_a_final_sort.split(','))
    else
      filtered_team_a_users
    end
  end

  def filtered_team_b_users
    filtered_users = team_b.present? ? build_excluded_user_filter(team_b.users) : []
    sort_users(filtered_users)
  end

  def team_b_users
    return [] if team_b.blank?

    if team_b_final_sort.present?
      team_b.users.where(id: team_b_final_sort.split(','))
    else
      filtered_team_b_users
    end
  end

  def team_users_for_user(user)
    if team_a.present? && team_a.users.include?(user)
      team_a_users
    elsif team_b.present? && team_b.users.include?(user)
      team_b_users
    else
      []
    end
  end

  def users_for_team(team)
    if team == team_a
      team_a_users
    elsif team == team_b
      team_b_users
    else
      []
    end
  end

  def build_excluded_user_filter(relation)
    if user_ids_to_omit.present?
      relation.where('users.ID NOT IN (?)', user_ids_to_omit)
    else
      relation
    end
  end

  def all_users
    team_a_users + team_b_users
  end

  def unfiltered_users
    team_a.users + team_b.users
  end

  def toggle_user(user)
    if all_users.include?(user)
      exclude_user(user)
    else
      include_user(user)
    end
  end

  def exclude_user(user)
    user_ids = user_ids_to_omit
    user_ids << user.id unless user_ids.include? user.id.to_s

    self.excluded_user_ids = user_ids.join(',')
    save
  end

  def include_user(user)
    user_ids = user_ids_to_omit
    user_ids.delete(user.id.to_s)

    if user_ids.count.positive?
      self.excluded_user_ids = user_ids.join(',')
    else
      self.excluded_user_ids = nil
    end

    save
  end

  def save_teams_sort
    self.team_a_final_sort = team_a_users.pluck(:id).join(',')
    self.team_b_final_sort = team_b_users.pluck(:id).join(',')
    save
  end
end
