module Updaters
  class ScorecardUpdating
    def self.update_scorecards_for_scores(scores, primary_scorecard, other_scorecards, notify_score_scores = false)
      scores.each do |score_param|
        Rails.logger.info { "score_param #{score_param}" }

        score_id = score_param[0].to_i
        strokes = score_param[1][:strokes].to_i
        date_scored = score_param[1][:date_scored]

        Rails.logger.info { "#{score_id} #{strokes}" }

        unless strokes.blank? || score_id.blank?
          score = Score.find(score_id)
          next if score.course_hole.blank?

          should_update = true
          if date_scored.present?
            scored_at = Time.zone.at(date_scored).to_datetime

            should_update = false if scored_at <= score.updated_at
          end

          if should_update
            score.strokes = strokes

            Notifications::ScoreNotification.notify_for_score(score) if notify_score_scores && !score.has_notified

            score.has_notified = true
            score.save

            Rails.logger.info { "Updating Score: #{score.id}" }

            scorecard_to_rescore = score.scorecard
            UpdateUserScorecardJob.perform_later(scorecard_to_rescore, []) if scorecard_to_rescore != primary_scorecard && scorecard_to_rescore.present?
          else
            Rails.logger.info { "Not Updating Scores - Too Old #{date_scored}" }
          end
        end
      end

      UpdateUserScorecardJob.perform_later(primary_scorecard, other_scorecards)
    end
  end
end
