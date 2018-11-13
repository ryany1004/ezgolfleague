module ScorecardAdjustedScore
  def score_or_maximum_for_hole(strokes:, course_handicap:, hole:)
    if course_handicap == 0
      Rails.logger.debug { "No Course Handicap" }

      return strokes
    end

    double_bogey = hole.par + 2

    Rails.logger.info { "Double Bogey for #{hole.hole_number} - #{double_bogey}" }

    if strokes <= double_bogey
      Rails.logger.info { "Strokes <= double_bogey: #{double_bogey}. #{strokes}" }

      strokes
    else
      adjusted_score = strokes

      case course_handicap
      when 0..9
        adjusted_score = double_bogey
      when 10..19
        adjusted_score = 7
      when 20..29
        adjusted_score = 8
      when 30..39
        adjusted_score = 9
      else
        adjusted_score = 10
      end

      if adjusted_score <= strokes
        Rails.logger.info { "Adjusted Score for #{hole.hole_number} (Par #{hole.par}) w/ strokes: #{strokes} = #{adjusted_score}. Course handicap: #{course_handicap}" }

        adjusted_score
      else
        Rails.logger.info { "Adjusted Score Was Too High... Bailing" }

        strokes
      end
    end
  end
end