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
    raise 'Unbalanced teams' unless teams_are_balanced?

    pairings = []

    team_a_users.each_with_index do |u, i|
      user_b = team_b_users[i]

      pairings << [u, user_b]
    end

    pairings
  end

  def users_with_matchup_indicator(team)
    matchups = []

    if team == team_a
      users = team_a_users
    else
      users = team_b_users
    end

    users.each_with_index do |u, i|
      matchups << { user: u, matchup_indicator: position_indicator_for_index(i) }
    end

    matchups
  end

  def matchup_indicator_for_user(user)
    if team_a.users.include? user
      users = team_a_users
    else
      users = team_b_users
    end

    users.each_with_index do |u, i|
      return position_indicator_for_index(i) if user == u
    end

    nil
  end

  def position_indicator_for_index(index)
    positions = %w[A B C D E F G H]

    positions[index]
  end

  def user_ids_to_omit
    split_ids = excluded_user_ids&.split(',')
    split_ids.presence || []
  end

  def team_a_users
    team_a.present? ? build_excluded_user_filter(team_a.users) : []
  end

  def team_b_users
    team_b.present? ? build_excluded_user_filter(team_b.users) : []
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
    user_ids << user.id unless user_ids.include? user.id

    self.excluded_user_ids = user_ids.join(',')
    save
  end

  def include_user(user)
    user_ids = user_ids_to_omit
    user_ids.delete(user.id.to_s)

    self.excluded_user_ids = user_ids.join(',')
    save
  end
end
