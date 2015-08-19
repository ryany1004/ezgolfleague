module AutoSchedulable
  extend ActiveSupport::Concern

  def schedule_golfers
    
    
    if self.tournament.auto_schedule_for_multi_day == 1
    
    elsif self.tournament.auto_schedule_for_multi_day == 2
    
    end
    
  end
  
end