module GameTypes
  class DerivedScorecardScore
    attr_accessor :strokes
    attr_accessor :course_hole
    attr_accessor :scorecard
    
    ##Model Stuff
    
    def id
      return -1
    end
    
    def associated_text
      return nil
    end
    
  end
end