module ScoringRuleScorecards
  class StablefordScorecard < ScoringRuleScorecards::BaseScorecard
    def name(shorten_for_print = false)
      return "Stableford"
    end

    def calculate_scores
      new_scores = []

      handicap_allowance = self.tournament_day.handicap_allowance(user: user)

      self.tournament_day.scorecard_base_scoring_rule.course_holes.each do |hole|
        score = DerivedScorecardScore.new
        score.strokes = self.score_for_hole(user, [], hole)
        score.net_strokes = self.score_for_hole(user, handicap_allowance, hole)
        score.course_hole = hole
        new_scores << score
      end

      self.scores = new_scores
    end

    def score_for_hole(user, handicap_allowance, hole)
      scorecard = self.tournament_day.primary_scorecard_for_user(user)
      return 0 if scorecard.blank?

      strokes = 0
      strokes = scorecard&.scores.where(course_hole: hole).first&.strokes

      handicap_allowance.each do |h|
        if h[:course_hole] == hole
          if h[:strokes] != 0
            strokes = strokes - h[:strokes]
          end
        end
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
