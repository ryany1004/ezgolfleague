module GameTypes
  class DerivedScorecard

    attr_accessor :user
    attr_accessor :tournament_team
    attr_accessor :underlying_tournament_day
    attr_accessor :scores

    def initialize
      self.scores = []
    end

    ##Model Stuff

    def id
      return -1
    end

    def tournament_day
      unless self.tournament_team.blank?
        return self.tournament_team.tournament_day
      else
        return self.underlying_tournament_day
      end
    end

    def game_type
      self.tournament_day.game_type
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

    ##Logic

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

    def gross_score
      return self.scores.map {|score| score.strokes }.sum
    end

    def net_score
      return 0
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
