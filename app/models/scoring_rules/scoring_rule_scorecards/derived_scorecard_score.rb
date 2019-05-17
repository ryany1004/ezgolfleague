module ScoringRuleScorecards
  class DerivedScorecardScore
    attr_accessor :strokes
    attr_accessor :net_strokes
    attr_accessor :display_net
    attr_accessor :course_hole
    attr_accessor :scorecard

    def initialize
      self.strokes = 0
      self.net_strokes = 0
      self.display_net = false
    end

    # Model Stuff

    def id
      -1
    end

    def associated_text
      nil
    end

    def display_score
      display_net ? net_strokes : strokes
    end

    def save
      # this is a no-op
    end
  end
end
