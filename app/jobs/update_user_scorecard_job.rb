require 'sidekiq/api'

class UpdateUserScorecardJob < ApplicationJob
  queue_as :calculations

  def perform(primary_scorecard, other_scorecards)
    if job_exists?(primary_scorecard)
      Rails.logger.info { "UpdateUserScorecardJob for #{primary_scorecard.id} already exists. Bailing..." }

      return
    end

    primary_user = primary_scorecard.golf_outing.user

    primary_scorecard.tournament_day.scoring_rules.each do |rule|
      next unless rule.calculate_each_entry?

      Rails.logger.debug { "Scoring #{rule.name} for #{primary_user.complete_name}" }

      CalculateNetScoresJob.perform_now(primary_scorecard) # this ensures we always have a net score posted

      scoring_computer = rule.scoring_computer
      result = scoring_computer.generate_tournament_day_result(user: primary_user)
      scoring_computer.after_updating_scores_for_scorecard(scorecard: primary_scorecard)

      other_scorecards.each do |other_scorecard|
        next if other_scorecard.golf_outing.blank?

        other_user = other_scorecard.golf_outing.user
        scoring_computer.generate_tournament_day_result(user: other_user)
        scoring_computer.after_updating_scores_for_scorecard(scorecard: other_scorecard)
      end

      scoring_computer.rank_results

      scoring_computer.send_did_score_notification(scorecard: primary_scorecard)

      clear_caches(primary_scorecard)

      Rails.logger.info { "Scoring: #{primary_scorecard.id}. User: #{primary_user.complete_name}. Result: #{result}" } if result.present?
    end
  end

  # this is a hack that should be replaced
  def job_exists?(primary_scorecard)
    queue = Sidekiq::Queue.new('ezgolfleague_production_calculations')
    queue.each do |j|
      parsed_job = JSON.parse(j.value)
      next if parsed_job.blank?

      parsed_args = parsed_job['args']
      next if parsed_args.blank? || parsed_args.first.blank?

      parsed_arguments = parsed_args.first['arguments']
      next if parsed_arguments.blank? || parsed_arguments.first.blank?

      global_id = parsed_arguments['_aj_globalid']
      next if global_id.blank?

      return true if global_id.include?(primary_scorecard.id.to_s)
    end

    false
  end

  def clear_caches(primary_scorecard)
    Rails.logger.info { "Expiring caches: #{primary_scorecard.tournament_day.cache_key('groups')}" }

    Rails.cache.delete(primary_scorecard.tournament_day.cache_key('groups'))
  end
end
