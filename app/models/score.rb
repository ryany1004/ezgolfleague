class Score < ActiveRecord::Base
  include Servable
  
  belongs_to :scorecard, inverse_of: :scores, touch: true
  belongs_to :course_hole
  
  after_save :touch_tournament
  
  def touch_tournament
    self.scorecard.tournament_day.touch
    self.scorecard.tournament_day.tournament.touch
  end
  
  def associated_text
    return self.scorecard.tournament_day.game_type.associated_text_for_score(self)
  end
    
  def course_hole_number
    return self.course_hole.hole_number.to_s
  end
  
  def course_hole_par
    return self.course_hole.par.to_s
  end
    
end
