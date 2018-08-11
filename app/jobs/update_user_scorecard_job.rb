class UpdateUserScorecardJob < ApplicationJob
  def perform(primary_scorecard, other_scorecards)
    Rails.logger.info { "Re-Scoring User #{primary_scorecard.golf_outing.user.complete_name}" }
    primary_scorecard.tournament_day.score_user(primary_scorecard.golf_outing.user)

    Rails.logger.info { "User Re-Scored, Updating After-Action" }
    primary_scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(primary_scorecard)

    other_scorecards.each do |other_scorecard|
      Rails.logger.info { "Updating Other Scorecard: #{other_scorecard.id}" }

      unless other_scorecard.golf_outing.blank?
        primary_scorecard.tournament_day.score_user(other_scorecard.golf_outing.user)
        primary_scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(other_scorecard)
      else
        Rails.logger.info { "Err, Failed: Updating Other Scorecard: #{other_scorecard.id}" }
      end
    end

    self.complication_notification(primary_scorecard) #send to the Apple Watch complication but only if we have not in the last few minutes

    self.clear_caches(primary_scorecard)

    unless primary_scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => primary_scorecard.id).blank?
      Rails.logger.info { "SCORE: Re-Scoring For Scorecard: #{primary_scorecard.id}. User: #{primary_scorecard.golf_outing.user.complete_name}. Net Score: #{primary_scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => primary_scorecard.id).first.net_score}" }
    end

    RankFlightsJob.perform_later(primary_scorecard.tournament_day)

    Rails.logger.info { "UpdateUserScorecardJob Completed" }
  end

  def complication_notification(primary_scorecard)
    complication_cache_key = "#{primary_scorecard.id}-last_complication_push"
    last_complication_push = Rails.cache.fetch(complication_cache_key)
    if last_complication_push.blank? || last_complication_push < 5.minutes.ago
      primary_scorecard.tournament_day.tournament.players.each do |p|
        slim_leaderboard = FetchingTools::LeaderboardFetching.create_slimmed_down_leaderboard(primary_scorecard.tournament_day)
    
        p.send_complication_notification(slim_leaderboard)
      end

      Rails.cache.write(complication_cache_key, DateTime.now)
    end
  end

  def clear_caches(primary_scorecard)
    Rails.logger.info { "Expiring caches: #{primary_scorecard.tournament_day.leaderboard_api_cache_key} | #{primary_scorecard.tournament_day.groups_api_cache_key}" }

    Rails.cache.delete(primary_scorecard.tournament_day.leaderboard_api_cache_key)
    Rails.cache.delete(primary_scorecard.tournament_day.groups_api_cache_key)
  end

end
