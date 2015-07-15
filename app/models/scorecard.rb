class Scorecard < ActiveRecord::Base
  belongs_to :golf_outing, inverse_of: :scorecards
  has_many :scores, -> { order("sort_order") }, inverse_of: :scorecard, :dependent => :destroy
  has_many :game_type_metadatum, inverse_of: :scorecard, :dependent => :destroy
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
    return self.tournament.game_type.player_score(self.golf_outing.user, true)
  end
  
  def front_nine_score(use_handicap = false)
    return self.tournament.game_type.player_score(self.golf_outing.user, use_handicap, [1, 2, 3, 4, 5, 6, 7, 8, 9])
  end
  
  def back_nine_score(use_handicap = false)
    return self.tournament.game_type.player_score(self.golf_outing.user, use_handicap, [10, 11, 12, 13, 14, 15, 16, 17, 18])
  end
  
  #Team Support
  
  def is_potentially_editable?
    return true
  end
  
  def should_highlight?
    return false
  end
  
  def name
    unless self.tournament.game_type.override_scorecard_name.blank?
      return self.tournament.game_type.override_scorecard_name
    else
      return self.golf_outing.user.complete_name
    end
  end
  
  ##Customization
  
  def should_subtotal?
    return true
  end
  
  def should_total?
    return true
  end
  
  def includes_extra_scoring_column?
    return self.tournament.game_type.includes_extra_scoring_column?
  end
  
  def extra_scoring_column_data
    return nil
  end
  
end
