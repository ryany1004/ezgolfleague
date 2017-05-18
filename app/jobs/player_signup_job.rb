class PlayerSignupJob < ProgressJob::Base
  def initialize(tournament_day, params)
    super progress_max: 3

    @tournament_day = tournament_day
    @params = params
  end

  def perform
    update_stage('Updating Signups')

    ##
    params = @params

    player_info = params[:player_signups][:member_id]

    unless player_info.blank?
      player_info.keys.each do |tg_id|
        group = TournamentGroup.find(tg_id)

        unless group.blank?
          player_info[tg_id].each_with_index do |p, i|
            unless p.last.blank?
              user = User.where(id: p.last).first

              unless user.blank?
                group.add_or_move_user_to_group(user)
              end
            end
          end
        end
      end
    end

    update_progress

    unless params[:player_signups][:golfer_team_ids].blank?
      params[:player_signups][:golfer_team_ids].keys.each do |k|
        group = TournamentGroup.find(k)

        contents = params[:player_signups][:golfer_team_ids][k]
        contents.each do |x|
          unless x.last.blank?
            index = x.first.to_i
            golfer_team_id = x.last.to_i

            team = GolferTeam.find(golfer_team_id)
            user = group.user_for_index(index)

            unless user.blank? || team.blank?
              existing_team = @tournament_day.golfer_team_for_player(user)

              if team != existing_team
                existing_team.users.delete(user) unless existing_team.blank?

                team.users << user
              end
            end
          end
        end
      end
    end

    update_progress

    #contests
    unless params[:player_signups][:contest_signups].blank?
      params[:player_signups][:contest_signups].keys.each do |k|
        group = TournamentGroup.find(k)

        contents = params[:player_signups][:contest_signups][k]
        contents.each do |x|
          unless x.last.blank?
            index = x.first.to_i
            contest_ids = x.last

            contests_should_be_enrolled = []
            contest_ids.each do |contest_id|
              contest = Contest.where(id: contest_id).first

              contests_should_be_enrolled << contest unless contest.blank?
            end

            user = group.user_for_index(index)

            unless user.blank?
              Rails.logger.debug { "User Index: #{index}. #{user.id}" }
              contests_enrolled = @tournament_day.paid_contests_for_player(user)

              #add to contests selected not already enrolled
              contests_to_add = contests_should_be_enrolled - contests_enrolled
              contests_to_add.each do |c|
                c.add_user(user)
              end

              #remove from contests not selected
              contests_to_remove = @tournament_day.tournament.paid_contests - contests_should_be_enrolled
              contests_to_remove.each do |c|
                Rails.logger.debug { "Removing #{c.id} from #{user.id}" }

                c.remove_user(user)
              end
            else
              Rails.logger.debug { "Contest User Was Nil #{contents}" }
            end
          end
        end
      end
    end

    update_progress
  end

end
