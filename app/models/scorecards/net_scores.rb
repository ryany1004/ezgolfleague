module ScorecardNetScores
  def net_scores(handicap_allowance:)
    scores = []

    self.scores.includes(:course_hole).each do |score|
      hole_score = score.strokes

      Rails.logger.debug { "Hole: #{score.course_hole.hole_number} - Score Strokes #{score.strokes}" }

      if !handicap_allowance.blank?
        handicap_allowance.each do |h|
          if h[:course_hole] == score.course_hole
            if h[:strokes] != 0
              Rails.logger.debug { "Handicap Adjusting Hole #{score.course_hole.hole_number} Score From #{hole_score} w/ Handicap Strokes #{h[:strokes]}" }

              adjusted_hole_score = hole_score - h[:strokes]
              hole_score = adjusted_hole_score if adjusted_hole_score > 0

              Rails.logger.debug { "Handicap Adjusted: #{hole_score}" }

              scores << hole_score
            end
          end
        end
      end
    end

    scores
  end
end