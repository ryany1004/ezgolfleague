module ScoringRuleScorecards
  class BestBallScorecard < ScoringRuleScorecards::BaseScorecard
    attr_accessor :should_use_handicap
    attr_accessor :handicap_indices
    attr_accessor :users_to_compare
    attr_accessor :team
    attr_accessor :course_hole_number_suppression_list

    def initialize
      super

      self.handicap_indices = {}
      self.course_hole_number_suppression_list = []
    end

    def name(shorten_for_print = false)
      if should_use_handicap
        if shorten_for_print
          'Net'
        else
          'Best Ball Net'
        end
      else
        if shorten_for_print
          'Gross'
        else
          'Best Ball Gross'
        end
      end
    end

    def should_subtotal?
      true
    end

    def should_total?
      true
    end

    def precalculated?
      true
    end

    def handicap_allowance_for_user(user)
      if handicap_indices[user.id.to_s]
        handicap_indices[user.id.to_s]
      else
        handicap_allowance = scoring_rule.handicap_computer.handicap_allowance(user: user)
        handicap_indices[user.id.to_s] = handicap_allowance

        handicap_allowance
      end
    end

    def calculate_scores
      if users_to_compare.blank?
        Rails.logger.debug { 'calculate_scores - 0 Users to Compare' }

        return
      end

      new_scores = []
      eligible_users = scoring_rule.users_eligible_for_payouts

      scoring_rule.tournament_day.scorecard_base_scoring_rule.course_holes.each do |hole|
        score = DerivedScorecardScore.new
        score.scorecard = self
        score.course_hole = hole
        score.display_net = should_use_handicap # this tells the score to display the net value

        if course_hole_number_suppression_list.include? hole.hole_number
          score.strokes = 0
        else
          comparable_scores = []
          comparable_net_scores = []

          users_to_compare.each do |user|
            next unless eligible_users.include? user # do not use if DQ

            scorecard = scoring_rule.tournament_day.primary_scorecard_for_user(user)
            raw_score = 0

            unless scorecard.blank? || scorecard.scores.blank?
              raw_score = scorecard.scores.find_by(course_hole: hole).strokes
            else
              Rails.logger.debug { "Raw Score is 0 - No Scorecard or Scores: \(scorecard.id) \(scorecard.scores&.where(course_hole: hole))" }
            end

            hole_score = raw_score
            comparable_scores << hole_score

            handicap_allowance = handicap_allowance_for_user(user)
            if handicap_allowance.present?
              net_score = adjusted_strokes(raw_score, handicap_allowance, hole)
              comparable_net_scores << net_score
            else
              comparable_net_scores << hole_score # without a handicap allowance these are effectively the same
            end
          end

          score.strokes = score_for_scores(comparable_scores, hole)
          score.net_strokes = score_for_scores(comparable_net_scores, hole)
        end

        new_scores << score
      end

      self.scores = new_scores
    end

    def score_for_scores(comparable_scores, _)
      return 0 if comparable_scores.blank?

      comparable_scores.reject!(&:zero?)

      sorted_scores = comparable_scores.sort! { |x, y| x <=> y }
      sorted_score = sorted_scores[0].present? ? sorted_scores[0] : 0

      [sorted_score, 0].max # you cannot have a negative score here
    end
  end
end
