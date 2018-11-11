module StrokePlayScoringRuleScoring
  def compute_user_score(user:, use_handicap: true, holes: [])
    return nil if !self.users.include? user

    if use_handicap
      handicap_allowance = self.tournament_day.handicap_allowance(user)

      Rails.logger.debug { "Handicap Allowance: #{handicap_allowance}" }
    end

    scorecard = self.tournament_day.primary_scorecard_for_user(user)
    if scorecard.blank?
      Rails.logger.debug { "Returning 0 - No Scorecard" }

      return 0
    end

    total_score = 0

    Rails.logger.debug { "Scorecard has #{scorecard.scores.count} scores." }

    scorecard.scores.includes(:course_hole).each do |score|
      should_include_score = true #allows us to calculate partial scores, i.e. back 9
      if holes.blank? == false
        should_include_score = false if !holes.include? score.course_hole.hole_number
      end

      if should_include_score == true
        hole_score = score.strokes

        Rails.logger.debug { "Hole: #{score.course_hole.hole_number} - Score Strokes #{score.strokes}" }

        #TODO: re-factor with below method
        if use_handicap && !handicap_allowance.blank?
          handicap_allowance.each do |h|
            if h[:course_hole] == score.course_hole
              if h[:strokes] != 0
                Rails.logger.debug { "Handicap Adjusting Hole #{score.course_hole.hole_number} Score From #{hole_score} w/ Handicap Strokes #{h[:strokes]}" }

                adjusted_hole_score = hole_score - h[:strokes]
                hole_score = adjusted_hole_score if adjusted_hole_score > 0

                Rails.logger.debug { "Handicap Adjusted: #{hole_score}" }
              end
            end
          end
        end

        total_score = total_score + hole_score
      end
    end

    total_score = 0 if total_score < 0

    Rails.logger.debug { "Base Score Computed: #{total_score}. User: #{user.complete_name} use handicap: #{use_handicap} holes: #{holes}" }

    total_score
  end
end