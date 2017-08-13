module Updaters
  class TournamentGroupUpdater

    def update_for_params(tournament_group, params)
      player_info = params[:player_submit][:member_id]
      players_signed_up = self.player_signup(tournament_group, player_info) unless player_info.blank?

      unless players_signed_up.blank?
        team_info = params[:player_submit][:golfer_team_ids]
        self.team_signup(tournament_group, team_info) unless team_info.blank?

        contest_info = params[:player_submit][:contest_signups]
        self.contest_signup(tournament_group, contest_info) unless contest_info.blank?
      end

      players_signed_up
    end

    def player_signup(tournament_group, player_info)
      players_signed_up = []

      player_info.keys.each do |slot_id|
        user = User.where(id: player_info[slot_id]).first

        unless user.blank?
          tournament_group.add_or_move_user_to_group(user)
          players_signed_up << user
        end
      end

      players_signed_up
    end

    def team_signup(tournament_group, team_info)
      team_info.keys.each do |slot_id|
        golf_outing = tournament_group.golf_outings[slot_id.to_i]

        unless golf_outing.blank?
          user = golf_outing.user
          team = GolferTeam.find(team_info[slot_id])

          unless user.blank? || team.blank?
            existing_team = tournament_group.tournament_day.golfer_team_for_player(user)

            if team != existing_team
              existing_team.users.delete(user) unless existing_team.blank?

              team.users << user
            end
          end
        end
      end
    end

    def contest_signup(tournament_group, contest_info)
      contest_info.keys.each do |slot_id|
        golf_outing = tournament_group.golf_outings[slot_id.to_i]

        unless golf_outing.blank?
          user = golf_outing.user

          unless user.blank?
            contests = contest_info[slot_id]
            contests.each do |contest_id|
              contests_should_be_enrolled = []

              unless contest_id.blank?
                contest = Contest.where(id: contest_id).first
                contests_should_be_enrolled << contest unless contest.blank?
              end

              contests_enrolled = tournament_group.tournament_day.paid_contests_for_player(user)

              #add to contests selected not already enrolled
              contests_to_add = contests_should_be_enrolled - contests_enrolled
              contests_to_add.each do |c|
                c.add_user(user)
              end

              #remove from contests not selected
              contests_to_remove = tournament_group.tournament_day.tournament.paid_contests - contests_should_be_enrolled

              contests_to_remove.each do |c|
                c.remove_user(user)
              end
            end
          end
        end
      end
    end
  end
end
