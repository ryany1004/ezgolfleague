module GameTypes
  class DerivedScorecard
    
    attr_accessor :user
    attr_accessor :golfer_team
    attr_accessor :scores
    
    def initialize
      self.scores = []
    end
    
    ##Model Stuff
    
    def id
      return -1
    end
    
    def tournament
      return self.golfer_team.tournament
    end
    
    def golf_outing
      return nil
    end
    
    ##Logic
    
    def should_highlight?
      return true
    end
    
    def is_potentially_editable?
      return false
    end
    
    def name
      return "Derived Score"
    end
    
    def net_score
      return 0
    end
    
    def calculate_scores
    end
    
  end
end