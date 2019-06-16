module ScoringRuleScorecards
  class StablefordScorecard < ScoringRuleScorecards::BaseScorecard
    def name(shorten_for_print = false)
      'Stableford'
    end

    def calculate_scores
      new_scores = []

      self.tournament_day.scorecard_base_scoring_rule.course_holes.each do |hole|
        score = DerivedScorecardScore.new
        score.strokes = self.score_for_hole(user, false, hole)
        score.net_strokes = self.score_for_hole(user, true, hole)
        score.course_hole = hole
        score.display_net = true
        new_scores << score
      end

      self.scores = new_scores
    end

    def score_for_hole(user, use_handicap, hole)
      scorecard = self.tournament_day.primary_scorecard_for_user(user)
      return 0 if scorecard.blank?

      score = scorecard&.scores.where(course_hole: hole).first
      return 0 if score.strokes.blank? || score.strokes == 0

      strokes = 0

      if use_handicap
        strokes = score&.net_strokes
      else
        strokes = score&.strokes
      end

      score = 0
      if self.is_double_eagle?(hole, strokes)
        score = self.scoring_rule.double_eagle_score
      elsif self.is_eagle?(hole, strokes)
        score = self.scoring_rule.eagle_score
      elsif self.is_birdie?(hole, strokes)
        score = self.scoring_rule.birdie_score
      elsif self.is_par?(hole, strokes)
        score = self.scoring_rule.par_score
      elsif self.is_bogey?(hole, strokes)
        score = self.scoring_rule.bogey_score
      elsif self.is_double_bogey_or_worse?(hole, strokes)
        score = self.scoring_rule.double_bogey_score
      end

      return score
    end

    def is_double_eagle?(hole, strokes)
      par = hole.par

      if strokes <= par - 3
      	true
      else
      	false
      end
    end

    def is_eagle?(hole, strokes)
      par = hole.par

      if strokes == par - 2
        true
      else
        false
      end
    end

    def is_birdie?(hole, strokes)
      par = hole.par

      if strokes == par - 1
        true
      else
        false
      end
    end

    def is_par?(hole, strokes)
      par = hole.par

      if par == strokes
        true
      else
        false
      end
    end

    def is_bogey?(hole, strokes)
      par = hole.par

      if strokes == par + 1
        true
      else
        false
      end
    end

    def is_double_bogey_or_worse?(hole, strokes)
      par = hole.par

      if strokes > par + 1
        true
      else
        false
      end
    end
  end
end
