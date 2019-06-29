module ScoringRuleScorecards
  class StablefordScorecard < ScoringRuleScorecards::BaseScorecard
    def name(shorten_for_print = false)
      'Stableford'
    end

    def should_subtotal?
      true
    end

    def should_total?
      true
    end

    def front_nine_score(use_handicap = false)
      if use_handicap
        tournament_day_results.first ? tournament_day_results.first.front_nine_net_score : 0
      else
        tournament_day_results.first ? tournament_day_results.first.front_nine_gross_score : 0
      end
    end

    def back_nine_score(use_handicap = false)
      if use_handicap
        tournament_day_results.first ? tournament_day_results.first.back_nine_net_score : 0
      else
        tournament_day_results.first ? tournament_day_results.first.back_nine_gross_score : 0
      end
    end

    def calculate_scores
      new_scores = []

      tournament_day.scorecard_base_scoring_rule.course_holes.each do |hole|
        score = DerivedScorecardScore.new
        score.strokes = score_for_hole(user, false, hole)
        score.net_strokes = score_for_hole(user, true, hole)
        score.course_hole = hole
        score.display_net = true
        new_scores << score
      end

      self.scores = new_scores
    end

    def score_for_hole(user, use_handicap, hole)
      scorecard = tournament_day.primary_scorecard_for_user(user)
      return 0 if scorecard.blank?

      score = scorecard.scores.find_by(course_hole: hole)
      return 0 if score.strokes.blank? || score.strokes.zero?

      strokes = 0

      if use_handicap
        strokes = score&.net_strokes
      else
        strokes = score&.strokes
      end

      score = 0
      if double_eagle?(hole, strokes)
        score = scoring_rule.double_eagle_score
      elsif eagle?(hole, strokes)
        score = scoring_rule.eagle_score
      elsif birdie?(hole, strokes)
        score = scoring_rule.birdie_score
      elsif par?(hole, strokes)
        score = scoring_rule.par_score
      elsif bogey?(hole, strokes)
        score = scoring_rule.bogey_score
      elsif double_bogey_or_worse?(hole, strokes)
        score = scoring_rule.double_bogey_score
      end

      Rails.logger.debug { "STABLEFORD score_for_hole #{user.complete_name} Handicap: #{use_handicap}. Hole #{hole.hole_number} - #{score}" }

      score
    end

    def double_eagle?(hole, strokes)
      par = hole.par
      strokes <= par - 3
    end

    def eagle?(hole, strokes)
      par = hole.par
      strokes == par - 2
    end

    def birdie?(hole, strokes)
      par = hole.par
      strokes == par - 1
    end

    def par?(hole, strokes)
      par = hole.par
      par == strokes
    end

    def bogey?(hole, strokes)
      par = hole.par
      strokes == par + 1
    end

    def double_bogey_or_worse?(hole, strokes)
      par = hole.par
      strokes > par + 1
    end
  end
end
