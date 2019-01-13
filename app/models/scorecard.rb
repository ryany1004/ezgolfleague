class Scorecard < ApplicationRecord
  include Servable
  include CacheKeyable

  include ::ScorecardNetScores
  include ::ScorecardAdjustedScore

  acts_as_paranoid

  belongs_to :golf_outing, inverse_of: :scorecard, touch: true
  has_many :scores, -> { order("sort_order") }, inverse_of: :scorecard, dependent: :destroy
  has_many :game_type_metadatum, inverse_of: :scorecard, dependent: :destroy
  has_many :tournament_day_results, inverse_of: :primary_scorecard, dependent: :destroy, foreign_key: "user_primary_scorecard_id"
  belongs_to :designated_editor, class_name: "User", foreign_key: "designated_editor_id", optional: true

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

  def scorecard_payload
    self.tournament_day.scorecard_base_scoring_rule.scorecard_api(scorecard: self)
  end

  def clear_primary_scorecard_cache
    return if self.golf_outing.user.blank?

    did_remove = self.tournament_day.delete_cached_primary_scorecard(user: self.golf_outing.user)

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
    self.tournament_day_results.first ? self.tournament_day_results.first&.gross_score : 0
  end

  def net_score
    self.tournament_day_results.first ? self.tournament_day_results.first&.net_score : 0
  end

  def front_nine_score(use_handicap = false)
    if use_handicap
      self.tournament_day_results.first ? self.tournament_day_results.first&.front_nine_net_score : 0
    else
      self.tournament_day_results.first ? self.tournament_day_results.first&.front_nine_gross_score : 0
    end
  end

  def back_nine_score(use_handicap = true)
    self.tournament_day_results.first ? self.tournament_day_results.first&.back_nine_net_score : 0
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
    self.golf_outing.course_handicap.to_i
  end

  def has_empty_scores?
    self.scores.each do |s|
      return true if s.strokes == 0 or s.strokes.blank?
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
    self.tournament_day.scoring_rules.each do |rule|
      overridden_name = rule.override_scorecard_name(scorecard: self)

      return overridden_name if overridden_name.present?
    end

    self.golf_outing.user.short_name
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
    self.tournament_day.scorecard_base_scoring_rule.includes_extra_scoring_column?
  end

  def extra_scoring_column_data
    nil
  end

end
