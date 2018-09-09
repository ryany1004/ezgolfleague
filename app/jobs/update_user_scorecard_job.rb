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

    RankFlightsJob.perform_later(primary_scorecard.tournament_day)

    SendComplicationNotificationJob.perform_later(primary_scorecard)

    self.clear_caches(primary_scorecard)

    unless primary_scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => primary_scorecard.id).blank?
      Rails.logger.info { "SCORE: Re-Scoring For Scorecard: #{primary_scorecard.id}. User: #{primary_scorecard.golf_outing.user.complete_name}. Net Score: #{primary_scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => primary_scorecard.id).first.net_score}" }
    end

    Rails.logger.info { "UpdateUserScorecardJob Completed" }
  end

  def clear_caches(primary_scorecard)
    Rails.logger.info { "Expiring caches: #{primary_scorecard.tournament_day.groups_api_cache_key}" }

    Rails.cache.delete(primary_scorecard.tournament_day.groups_api_cache_key)
  end
end
