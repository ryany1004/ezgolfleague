class Scorecard < ActiveRecord::Base
  belongs_to :golf_outing, inverse_of: :scorecards
  has_many :scores, -> { order("sort_order") }, inverse_of: :scorecard, :dependent => :destroy
  belongs_to :designated_editor, :class_name => "User", :foreign_key => "designated_editor_id"
  
  after_save :set_course_handicap
  
  accepts_nested_attributes_for :scores
  
  def tournament
    return self.golf_outing.team.tournament_group.tournament
  end
  
  def set_course_handicap(force_recalculation = false)
    if force_recalculation == true or (self.golf_outing.course_handicap.blank? or self.golf_outing.course_handicap == 0)
      calculated_course_handicap = self.golf_outing.user.course_handicap(self.tournament.course, self.golf_outing.course_tee_box)
      calculated_course_handicap = 0 if calculated_course_handicap.blank?
      
      self.golf_outing.course_handicap = calculated_course_handicap
      self.golf_outing.save
    end
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
  
  #Team Support
  
  def is_potentially_editable?
    return true
  end
  
  def should_highlight?
    return false
  end
  
  def name
    return self.golf_outing.user.complete_name
  end
  
end
