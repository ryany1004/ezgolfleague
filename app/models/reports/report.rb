module Reports
  class Report
   attr_accessor :tournament_day
    
    def initialize(tournament_day)    
      self.tournament_day = tournament_day
    end
    
  end
end