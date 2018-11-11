module Users
	class ResultName
    def self.result_name_for_user(user, tournament_day)
      if tournament_day.golfer_teams.count == 0
        return user.complete_name
      else
        team_name = ""

        team = tournament_day.golfer_team_for_player(user)
        team&.users&.each do |team_user|
          team_name = team_name + "#{team_user.complete_name}"

          team_name = team_name + " / " unless team_user == team.users.last
        end

        return team_name
      end
    end
	end
end