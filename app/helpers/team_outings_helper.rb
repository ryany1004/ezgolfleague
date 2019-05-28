module TeamOutingsHelper
  def user_playing_status_indicator(tournament_day, team, user)
    matchup = tournament_day.league_season_team_matchup_for_team(team)

    if matchup.all_users.include?(user)
      user.complete_name
    else
      "<strike>#{user.complete_name}</strike>".html_safe
    end
  end
end
