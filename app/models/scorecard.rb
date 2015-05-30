class Scorecard < ActiveRecord::Base
  belongs_to :golf_outing, inverse_of: :scorecards
  has_many :scores, -> { order("sort_order") }, inverse_of: :scorecard, :dependent => :destroy
  belongs_to :designated_editor, :class_name => "User", :foreign_key => "designated_editor_id"
  
  accepts_nested_attributes_for :scores
  
  def tournament
    return self.golf_outing.team.tournament_group.tournament
  end
  
  def net_score    
    net_score = 0
    
    handicap_allowance = self.golf_outing.team.tournament_group.tournament.handicap_allowance(self.golf_outing.user)
    
    self.scores.each do |score|
      adjustment = 0
      
      handicap_allowance.each do |h|      
        adjustment = h[:strokes] if score.course_hole == h[:course_hole]
      end
      
      net_score += score.strokes - adjustment
    end

    return net_score
  end
  
end
