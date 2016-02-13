module Updaters
  class ScorecardUpdating
    
    def self.update_scorecards_for_scores(scores, primary_scorecard, other_scorecards)
      scores.each do |score_param|
        Rails.logger.info { "score_param #{score_param}" }
      
        score_id = score_param[0].to_i
        strokes = score_param[1][:strokes]
        date_scored = score_param[1][:date_scored]
      
        Rails.logger.info { "#{score_id} #{strokes}" }
        
        unless strokes.blank? or score_id.blank?
          score = Score.find(score_id)
          
          should_update = true
          unless date_scored.blank?
            scored_at = Time.at(date_scored).to_datetime
          
            should_update = false if scored_at <= score.updated_at
          end
          
          if should_update == true
            score.strokes = strokes
            score.save
            
            Rails.logger.info { "Updating Score: #{score.id}" }
            
            scorecard_to_rescore = score.scorecard
            Delayed::Job.enqueue UpdateUserScorecardJob.new(scorecard_to_rescore, []) unless scorecard_to_rescore.blank?
          else
            Rails.logger.info { "Not Updating Scores - Too Old #{date_scored}" }
          end
        end
      end
    
      Delayed::Job.enqueue UpdateUserScorecardJob.new(primary_scorecard, other_scorecards)
    end
    
  end
end