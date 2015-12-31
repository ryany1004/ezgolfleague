module UpdatingTools
  class ScorecardUpdating
    
    def self.update_scorecards_for_scores(scores, primary_scorecard, other_scorecards)
      scores.each do |score_param|
        Rails.logger.info { "#{score_param}" }
      
        score_id = score_param[0].to_i
        strokes = score_param[1][:strokes]
      
        Rails.logger.info { "#{score_id} #{strokes}" }
      
        unless strokes.blank? or score_id.blank?
          score = Score.find(score_id)
          score.strokes = strokes
          score.save
        end
      end
    
      Rails.logger.info { "SCORE: Re-Scoring For Scorecard: #{primary_scorecard.id}. User: #{primary_scorecard.golf_outing.user.complete_name}. Net Score: #{primary_scorecard.tournament_day.tournament_day_results.where(:user_primary_scorecard_id => primary_scorecard.id).first.net_score}" }
    
      primary_scorecard.tournament_day.score_user(primary_scorecard.golf_outing.user)
      primary_scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(primary_scorecard)
    
      other_scorecards.each do |other_scorecard|
        primary_scorecard.tournament_day.score_user(other_scorecard.golf_outing.user) unless other_scorecard.golf_outing.blank?
        primary_scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(other_scorecard)
      end
    end
    
  end
end