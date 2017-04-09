class GolfOutingsController < BaseController
  before_filter :fetch_tournament
  before_filter :set_stage

  def players
    @schedule_options = { 0 => "Manual", 1 => "Automatic: Worst Score First", 2 => "Automatic: Best Score First" }

    @page_title = "Signups for #{@tournament.name}"
  end

  def update_players
    # player_info = params[:player_signups][:member_id]
    #
    # unless player_info.blank?
    #   player_info.keys.each do |tg_id|
    #     group = TournamentGroup.find(tg_id)
    #
    #     unless group.blank?
    #       player_info[tg_id].each_with_index do |p, i|
    #         unless p.last.blank?
    #           user = User.where(id: p.last).first
    #
    #           unless user.blank?
    #             group.add_or_move_user_to_group(user)
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
    #
    # unless params[:player_signups][:golfer_team_ids].blank?
    #   params[:player_signups][:golfer_team_ids].keys.each do |k|
    #     group = TournamentGroup.find(k)
    #
    #     contents = params[:player_signups][:golfer_team_ids][k]
    #     contents.each do |x|
    #       unless x.last.blank?
    #         index = x.first.to_i
    #         golfer_team_id = x.last.to_i
    #
    #         team = GolferTeam.find(golfer_team_id)
    #         user = group.user_for_index(index)
    #
    #         unless user.blank? || team.blank?
    #           existing_team = @tournament_day.golfer_team_for_player(user)
    #
    #           if team != existing_team
    #             existing_team.users.delete(user) unless existing_team.blank?
    #
    #             team.users << user
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
    #
    # #contests
    # unless params[:player_signups][:contest_signups].blank?
    #   params[:player_signups][:contest_signups].keys.each do |k|
    #     group = TournamentGroup.find(k)
    #
    #     contents = params[:player_signups][:contest_signups][k]
    #     contents.each do |x|
    #       unless x.last.blank?
    #         index = x.first.to_i
    #         contest_ids = x.last
    #
    #         contests_should_be_enrolled = []
    #         contest_ids.each do |contest_id|
    #           contest = Contest.where(id: contest_id).first
    #
    #           contests_should_be_enrolled << contest unless contest.blank?
    #         end
    #
    #         user = group.user_for_index(index)
    #
    #         unless user.blank?
    #           Rails.logger.debug { "User Index: #{index}. #{user.id}" }
    #           contests_enrolled = @tournament_day.paid_contests_for_player(user)
    #
    #           #add to contests selected not already enrolled
    #           contests_to_add = contests_should_be_enrolled - contests_enrolled
    #           contests_to_add.each do |c|
    #             c.add_user(user)
    #           end
    #
    #           #remove from contests not selected
    #           contests_to_remove = @tournament.paid_contests - contests_should_be_enrolled
    #           contests_to_remove.each do |c|
    #             Rails.logger.debug { "Removing #{c.id} from #{user.id}" }
    #
    #             c.remove_user(user)
    #           end
    #         else
    #           Rails.logger.debug { "Contest User Was Nil #{contents}" }
    #         end
    #       end
    #     end
    #   end
    # end

    # redirect_to league_tournament_day_players_path(@tournament.league, @tournament, @tournament_day), :flash => { :success => "Your registration updates have been submitted." }

    @job = Delayed::Job.enqueue PlayerSignupJob.new(params)

    redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "Your player signup submissions are being processed. This usually takes a minute or two to complete processing." }
  end

  def delete_signup
    tournament_group = TournamentGroup.find(params[:group_id])
    user = User.find(params[:user_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end

    @tournament_day.remove_player_from_group(tournament_group, user, true)

    redirect_to league_tournament_day_players_path(@tournament.league, @tournament, @tournament_day), :flash => { :success => "The registration was successfully deleted." }
  end

  def disqualify_signup
    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end

    user = User.find(params[:user_id])
    golf_outing = @tournament_day.golf_outing_for_player(user)
    golf_outing.disqualify

    redirect_to league_tournament_day_players_path(@tournament.league, @tournament, @tournament_day), :flash => { :success => "The player qualification status changed. You may need to re-finalize the tournament." }
  end

  private

  def set_stage
    @stage_name = "players#{@tournament_day.id}"
  end

  def fetch_tournament
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_day = TournamentDay.find(params[:tournament_day_id])
    @tournament_groups = @tournament_day.tournament_groups

    @league_members = @tournament.league.users
  end

end
