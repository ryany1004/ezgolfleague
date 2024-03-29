module Play::ScorecardsHelper
  def front_nine_handicap_for_scorecard(scorecard, print_mode)
    handicap_score = scorecard.front_nine_score(true)
    non_handicap_score = scorecard.front_nine_score(false)

    return '' if print_mode && handicap_score.zero?

    if scorecard.can_display_handicap? && handicap_score != non_handicap_score
      if print_mode == false
        return "<span class='label label-success'>#{handicap_score}</span>".html_safe
      else
        return handicap_score
      end
    else
      return nil
    end
  end

  def back_nine_handicap_for_scorecard(scorecard, print_mode)
    handicap_score = scorecard.back_nine_score(true)
    non_handicap_score = scorecard.back_nine_score(false)

    return '' if print_mode == true && handicap_score.zero?

    if scorecard.can_display_handicap? && handicap_score != non_handicap_score
      if !print_mode
        return "<span class='label label-success'>#{handicap_score}</span>".html_safe
      else
        return handicap_score
      end
    else
      return nil
    end
  end

  def scores_for_scorecards_for_course_hole(scorecards, course_hole)
    scores = []

    scorecards.each do |scorecard|
      scorecard.scores.each do |score|
        scores << score if score.course_hole == course_hole
      end
    end

    scores
  end
end
