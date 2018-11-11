class Scorecard < ApplicationRecord
  include Servable
  include ScorecardNetScores
  include ScorecardAdjustedScore

  acts_as_paranoid

  belongs_to :golf_outing, inverse_of: :scorecard, touch: true
  has_many :scores, -> { order("sort_order") }, inverse_of: :scorecard, dependent: :destroy
  has_many :game_type_metadatum, inverse_of: :scorecard, dependent: :destroy
  has_many :tournament_day_results, inverse_of: :primary_scorecard, dependent: :destroy, foreign_key: "user_primary_scorecard_id"
  belongs_to :designated_editor, class_name: "User", foreign_key: "designated_editor_id"

  after_save :set_course_handicap
  before_destroy :clear_primary_scorecard_cache

  accepts_nested_attributes_for :scores, :golf_outing

  def tournament_day
    self.golf_outing.tournament_group.tournament_day
  end

  def user
    self.golf_outing.user
  end

  def league
    self.tournament_day.tournament.league
  end

  def clear_primary_scorecard_cache
    return if self.golf_outing.user.blank?

    cache_key = self.golf_outing.tournament_group.tournament_day.scorecard_id_cache_key(self.golf_outing.user)

    did_remove = Rails.cache.delete(cache_key)

    Rails.logger.debug { "Removed Cache Key: #{did_remove}" }
  end

  def set_course_handicap(force_recalculation = false)
    if self.tournament_day.flight_for_player(self.golf_outing.user).blank?
      logger.info { "No Flight for User: #{self.golf_outing.user.complete_name}" }

      return
    end

    if force_recalculation == true or (self.golf_outing.course_handicap.blank? or self.golf_outing.course_handicap == 0)
      Rails.logger.debug { "Recalculating handicaps..." }

      calculated_course_handicap = self.golf_outing.user.course_handicap_for_golf_outing(self.golf_outing)
      calculated_course_handicap = 0 if calculated_course_handicap.blank?

      Rails.logger.info { "Recalculated Course Handicap For #{self.golf_outing.user.complete_name}: #{calculated_course_handicap} for Scorecard #{self.id}" }

      outing = self.golf_outing
      outing.update_column(:course_handicap, calculated_course_handicap) #prevent infinite loop
    else
      Rails.logger.info { "Did Not Re-Calculate Handicap For User #{self.golf_outing.user.complete_name}" }
    end
  end

  def gross_score
    return self.scores.map {|score| score.strokes }.sum
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
      flight.display_name
    else
      nil
    end
  end

  def course_handicap
    self.tournament_day.game_type.course_handicap_for_game_type(self.golf_outing).to_i
  end

  def has_empty_scores?
    self.scores.each do |s|
      true if s.strokes == 0 or s.strokes.blank?
    end

    false
  end

  def last_hole_played
    self.scores.each_with_index do |score, i|
      if score == self.scores.last and score.strokes > 0
        "F" #finished
      else
        "#{i}" if score.strokes == 0
      end
    end

    nil
  end

  # Permissions

  def user_can_view?(user)
    return true if user.is_super_user
    return true if self.user == user
    return false if user.blank?

    return true if self.league.users.include?(user)

    false
  end

  def user_can_edit?(user)
    return true if user.is_super_user
    return true if self.user == user
    return false if user.blank?

    return true if self.league.league_admins.include?(user)

    false
  end

  #Team Support

  def is_potentially_editable?
    true
  end

  def should_highlight?
    false
  end

  def name(shorten_for_print = false)
    override_name = self.tournament_day.game_type.override_scorecard_name_for_scorecard(self)

    unless override_name.blank?
      override_name
    else
      self.golf_outing.user.short_name
    end
  end

  def individual_name
    self.golf_outing.user.complete_name
  end

  ##Customization

  def can_display_handicap?
    true
  end

  def should_subtotal?
    true
  end

  def should_total?
    true
  end

  def includes_extra_scoring_column?
    self.tournament_day.game_type.includes_extra_scoring_column?
  end

  def extra_scoring_column_data
    nil
  end

end
