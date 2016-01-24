class Scorecard < ActiveRecord::Base
  include Servable
  
  belongs_to :golf_outing, inverse_of: :scorecard
  has_many :scores, -> { order("sort_order") }, inverse_of: :scorecard, :dependent => :destroy
  has_many :game_type_metadatum, inverse_of: :scorecard, :dependent => :destroy
  has_many :tournament_day_results, inverse_of: :primary_scorecard, :dependent => :destroy, :foreign_key => "user_primary_scorecard_id"
  belongs_to :designated_editor, :class_name => "User", :foreign_key => "designated_editor_id"
  
  after_save :set_course_handicap
  
  accepts_nested_attributes_for :scores
  
  def tournament_day
    return self.golf_outing.tournament_group.tournament_day
  end
  
  def set_course_handicap(force_recalculation = false)
    if force_recalculation == true or (self.golf_outing.course_handicap.blank? or self.golf_outing.course_handicap == 0)
      calculated_course_handicap = self.golf_outing.user.course_handicap(self.tournament_day.course, self.golf_outing.course_tee_box)
      calculated_course_handicap = 0 if calculated_course_handicap.blank?
      
      Rails.logger.debug { "Recalculated Course Handicap For #{self.golf_outing.user.complete_name}: #{calculated_course_handicap}" }
      
      self.golf_outing.course_handicap = calculated_course_handicap
      self.golf_outing.save
    else
      Rails.logger.debug { "Did Not Re-Calculate For User #{self.golf_outing.user.complete_name}" }
    end
  end
  
  def net_score
    return self.tournament_day.game_type.player_score(self.golf_outing.user, true)
  end
  
  def front_nine_score(use_handicap = false)
    return self.tournament_day.game_type.player_score(self.golf_outing.user, use_handicap, [1, 2, 3, 4, 5, 6, 7, 8, 9])
  end
  
  def back_nine_score(use_handicap = false)
    return self.tournament_day.game_type.player_score(self.golf_outing.user, use_handicap, [10, 11, 12, 13, 14, 15, 16, 17, 18])
  end
  
  def flight_number
    flight = self.tournament_day.flight_for_player(self.golf_outing.user)
    
    unless flight.blank?
      return flight.flight_number
    else
      return nil
    end
  end
  
  def course_handicap
    return self.golf_outing.course_handicap.to_i
  end
  
  def has_empty_scores?
    self.scores.each do |s|
      return true if s.strokes == 0 or s.strokes.blank?
    end
    
    return false
  end
  
  def last_hole_played
    self.scores.each_with_index do |score, i|
      return "#{i}" if score.strokes == 0
    end
    
    return nil
  end
  
  #Team Support
  
  def is_potentially_editable?
    return true
  end
  
  def should_highlight?
    return false
  end
  
  def name
    override_name = self.tournament_day.game_type.override_scorecard_name_for_scorecard(self)
    
    unless override_name.blank?
      return override_name
    else
      return self.golf_outing.user.short_name
    end
  end
  
  def individual_name
    return self.golf_outing.user.complete_name
  end
  
  ##Customization
  
  def can_display_handicap?    
    return true
  end
  
  def should_subtotal?
    return true
  end
  
  def should_total?
    return true
  end
  
  def includes_extra_scoring_column?
    return self.tournament_day.game_type.includes_extra_scoring_column?
  end
  
  def extra_scoring_column_data
    return nil
  end
  
end
