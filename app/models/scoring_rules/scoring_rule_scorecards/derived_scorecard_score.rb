module ScoringRuleScorecards
  class DerivedScorecardScore
    attr_accessor :strokes
    attr_accessor :net_strokes
    attr_accessor :course_hole
    attr_accessor :scorecard
    
    def initialize
      self.strokes = 0
      self.net_strokes = 0
    end

    # Model Stuff
    
    def id
      return -1
    end
    
    def associated_text
      return nil
    end
    
    def save
      #this is a no-op
    end
  end
end