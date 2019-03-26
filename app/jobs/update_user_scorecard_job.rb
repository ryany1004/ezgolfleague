class UpdateUserScorecardJob < ApplicationJob
  def perform(primary_scorecard, other_scorecards)
    primary_user = primary_scorecard.golf_outing.user

    primary_scorecard.tournament_day.scoring_rules.each do |rule|
      next if !rule.calculate_each_entry?

      Rails.logger.debug { "Scoring #{rule.name} for #{primary_user.complete_name}" }

      scoring_computer = rule.scoring_computer
      result = scoring_computer.generate_tournament_day_result(user: primary_user)
      scoring_computer.after_updating_scores_for_scorecard(scorecard: primary_scorecard)

      other_scorecards.each do |other_scorecard|
        if other_scorecard.golf_outing.present?
          other_user = other_scorecard.golf_outing.user

          scoring_computer.generate_tournament_day_result(user: other_user)
          scoring_computer.after_updating_scores_for_scorecard(scorecard: other_scorecard)
        end
      end

      scoring_computer.rank_results

      scoring_computer.send_did_score_notification(scorecard: primary_scorecard)

      self.clear_caches(primary_scorecard)

      CalculateNetScoresJob.perform_later(primary_scorecard) # this ensures we always have a net score posted
      
      Rails.logger.info { "Scoring: #{primary_scorecard.id}. User: #{primary_user.complete_name}. Result: #{result.to_s}" } if result.present?
    end
  end

  def clear_caches(primary_scorecard)
    Rails.logger.info { "Expiring caches: #{primary_scorecard.tournament_day.cache_key("groups")}" }

    Rails.cache.delete(primary_scorecard.tournament_day.cache_key("groups"))
  end
end