module ScoringRuleScorecards
  class BaseScorecard
    attr_accessor :user
    attr_accessor :scoring_rule
    attr_accessor :scores

    def initialize
      self.scores = []
    end

    def id
      (self.user.id * self.scoring_rule.id) * -1 # creates a unique, non-player ID for the scorecard
    end

    def tournament_day
      self.scoring_rule.tournament_day
    end

    def golf_outing
      return nil
    end

    def flight_number
      return nil
    end

    def course_handicap
      return nil
    end

    def should_highlight?
      return true
    end

    def is_potentially_editable?
      return false
    end

    def has_empty_scores?
      return false
    end

    def name(shorten_for_print = false)
      return "Derived Score"
    end

    def individual_name
      return name
    end

    def precalculated?
      false
    end

    def gross_score
      scores.map { |score| score.strokes }.sum
    end

    def net_score
      scores.map { |score| score.net_strokes }.sum
    end

    def adjusted_score
      gross_score
    end

    def front_nine_score(use_handicap = false)
      return 0
    end

    def back_nine_score(use_handicap = false)
      return 0
    end

    def should_subtotal?
      return false
    end

    def can_display_handicap?
      return true
    end

    def should_total?
      return false
    end

    def calculate_scores
      return nil
    end

    def extra_scoring_column_data
      return nil
    end

    def matchup_position_indicator
      nil
    end

    def adjusted_strokes(raw_strokes, handicap_allowance, course_hole)
      hole_score = raw_strokes

      handicap_allowance.each do |h|
        if h[:course_hole] == course_hole
          if h[:strokes] != 0
            hole_score = hole_score - h[:strokes]
          end
        end
      end

      return hole_score
    end
  end
end
