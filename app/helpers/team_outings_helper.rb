module TeamOutingsHelper
  def user_playing_status_indicator(tournament_day, team, user)
    matchup = tournament_day.league_season_team_matchup_for_team(team)

    if matchup.all_users.include?(user)
      user.complete_name
    else
      "<strike>#{user.complete_name}</strike>".html_safe
    end
  end

  def user_matchup_indicator(tournament_day, team, user)
    matchup = tournament_day.league_season_team_matchup_for_team(team)
    return matchup.matchup_indicator_for_user(user) if matchup.present?

    '&nbsp;'.html_safe
  end

  def user_matchup_selector(tournament_day, team, user)
    matchup = tournament_day.league_season_team_matchup_for_team(team)
    return '&nbsp;'.html_safe if matchup.blank? || matchup.matchup_indicator_for_user(user).blank?

    select(:team_update, user.id, ['A', 'B', 'C', 'D', 'E', 'F'], { selected: matchup.matchup_indicator_for_user(user) })
  end
end
