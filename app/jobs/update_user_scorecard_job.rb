class UpdateUserScorecardJob < ProgressJob::Base
  def initialize(primary_scorecard, other_scorecards)
    super progress_max: 2 + other_scorecards.count

    @primary_scorecard = primary_scorecard
    @other_scorecards = other_scorecards
  end

  def perform
    update_stage('Re-Scoring User')

    #TODO: audit and re-enable
    # #check for changes in leaderboard
    # leaderboard_before = @primary_scorecard.tournament_day.game_type.flights_with_rankings

    Rails.logger.info { "Re-Scoring User #{@primary_scorecard.golf_outing.user.complete_name}" }
    @primary_scorecard.tournament_day.score_user(@primary_scorecard.golf_outing.user)

    update_progress

    Rails.logger.info { "User Re-Scored, Updating After-Action" }
    @primary_scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(@primary_scorecard)

    @other_scorecards.each do |other_scorecard|
      Rails.logger.info { "Updating Other Scorecard: #{other_scorecard.id}" }

      unless other_scorecard.golf_outing.blank?
        @primary_scorecard.tournament_day.score_user(other_scorecard.golf_outing.user)
        @primary_scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(other_scorecard)
      else
        Rails.logger.info { "Err, Failed: Updating Other Scorecard: #{other_scorecard.id}" }
      end

      update_progress
    end

    #TODO: audit and re-enable
    # #check for changes in leaderboard
    # leaderboard_after = @primary_scorecard.tournament_day.game_type.flights_with_rankings
    # if leaderboard_before != leaderboard_after
    #   Rails.logger.info { "Sending Notifications for Complications" }
    #
    #   @primary_scorecard.tournament_day.tournament.players.each do |p|
    #     slim_leaderboard = FetchingTools::LeaderboardFetching.create_slimmed_down_leaderboard(@primary_scorecard.tournament_day)
    #
    #     p.send_complication_notification(slim_leaderboard)
    #   end
    # end

    Rails.logger.info { "Expiring caches: #{@primary_scorecard.tournament_day.leaderboard_api_cache_key} | #{@primary_scorecard.tournament_day.groups_api_cache_key}" }

    Rails.cache.delete(@primary_scorecard.tournament_day.leaderboard_api_cache_key)
    Rails.cache.delete(@primary_scorecard.tournament_day.groups_api_cache_key)

    unless @primary_scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => @primary_scorecard.id).blank?
      Rails.logger.info { "SCORE: Re-Scoring For Scorecard: #{@primary_scorecard.id}. User: #{@primary_scorecard.golf_outing.user.complete_name}. Net Score: #{@primary_scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => @primary_scorecard.id).first.net_score}" }
    end

    update_progress

    Rails.logger.info { "UpdateUserScorecardJob Completed" }
  end

end
