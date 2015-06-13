class Score < ActiveRecord::Base
  belongs_to :scorecard, inverse_of: :scores
  belongs_to :course_hole
  
  def associated_text
    return self.scorecard.tournament.game_type.associated_text_for_score(self)
  end
    
end
