class ResultName
  def self.result_name_for_user(user, scoring_rule)
    if scoring_rule.tournament_day.stroke_play_scoring_rule || scoring_rule.tournament_day.daily_teams.count.zero?
      user.complete_name
    else
      team_name = ''

        team = scoring_rule.tournament_day.daily_team_for_player(user)
        team&.users&.each do |team_user|
          team_name = team_name + team_user.complete_name

          team_name = team_name + ' / ' unless team_user == team.users.last
        end

        team_name
    end
  end
end
