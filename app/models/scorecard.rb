class Scorecard < ApplicationRecord
  include Servable
  include CacheKeyable

  include ::ScorecardNetScores
  include ::ScorecardAdjustedScore

  acts_as_paranoid

  belongs_to :golf_outing, inverse_of: :scorecard, touch: true
  has_many :scores, -> { order('sort_order') }, inverse_of: :scorecard, dependent: :destroy
  has_many :game_type_metadatum, inverse_of: :scorecard, dependent: :destroy
  has_many :tournament_day_results, inverse_of: :primary_scorecard, dependent: :destroy, foreign_key: 'user_primary_scorecard_id'
  belongs_to :designated_editor, class_name: 'User', foreign_key: 'designated_editor_id', optional: true

  after_save :set_course_handicap
  before_destroy :clear_primary_scorecard_cache

  delegate :user, to: :golf_outing

  accepts_nested_attributes_for :scores, :golf_outing

  def tournament_day
    golf_outing.tournament_group.tournament_day
  end

  def league
    tournament_day.tournament.league
  end

  def scorecard_payload
    tournament_day.scorecard_base_scoring_rule.scorecard_api(scorecard: self)
  end

  def clear_primary_scorecard_cache
    return if golf_outing.user.blank?

    did_remove = tournament_day.delete_cached_primary_scorecard(user: golf_outing.user)

    Rails.logger.debug { "Removed Cache Key: #{did_remove}" }
  end

  def set_course_handicap(force_recalculation = false)
    if tournament_day.flight_for_player(golf_outing.user).blank?
      logger.info { "No Flight for User: #{golf_outing.user.complete_name}" }

      return
    end

    if force_recalculation || (golf_outing.course_handicap.blank? || golf_outing.course_handicap.zero?)
      Rails.logger.debug { 'Recalculating handicaps...' }

      calculated_course_handicap = golf_outing.user.course_handicap_for_golf_outing(golf_outing)
      calculated_course_handicap = 0 if calculated_course_handicap.blank?

      Rails.logger.info { "Recalculated Course Handicap For #{golf_outing.user.complete_name}: #{calculated_course_handicap} for Scorecard #{id}" }

      outing = golf_outing
      outing.update_column(:course_handicap, calculated_course_handicap) # prevent infinite loop
    else
      Rails.logger.info { "Did Not Re-Calculate Handicap For User #{golf_outing.user.complete_name}" }
    end
  end

  def gross_score
    tournament_day_results.first ? tournament_day_results.first&.gross_score : 0
  end

  def net_score
    tournament_day_results.first ? tournament_day_results.first&.net_score : 0
  end

  def front_nine_score(use_handicap = false)
    if use_handicap
      tournament_day_results.first ? tournament_day_results.first&.front_nine_net_score : 0
    else
      tournament_day_results.first ? tournament_day_results.first&.front_nine_gross_score : 0
    end
  end

  def back_nine_score(use_handicap = false)
    if use_handicap
      tournament_day_results.first ? tournament_day_results.first&.back_nine_net_score : 0
    else
      tournament_day_results.first ? tournament_day_results.first&.back_nine_gross_score : 0
    end
  end

  def flight_number
    flight = tournament_day.flight_for_player(golf_outing.user)
    flight.display_name if flight.present?
  end

  def course_handicap
    golf_outing.course_handicap.to_i
  end

  def has_empty_scores?
    scores.each do |s|
      return true if s.strokes.zero? || s.strokes.blank?
    end

    false
  end

  def delete_empty_scores!
    scores.each do |s|
      s.delete if s.strokes.zero? || s.strokes.blank?
    end
  end

  def last_hole_played
    scores.each_with_index do |score, i|
      if score == scores.last && score.strokes.positive?
        return 'F' # finished
      else
        return i.to_s if score.strokes.zero?
      end
    end

    nil
  end

  # Permissions

  def user_can_view?(user)
    return true if user.is_super_user
    return true if self.user == user
    return false if user.blank?

    return true if league.users.include?(user)

    false
  end

  def user_can_edit?(user)
    return true if user.is_super_user
    return true if self.user == user
    return false if user.blank?

    return true if eague.league_admins.include?(user)

    false
  end

  # Team Support

  def is_potentially_editable?
    true
  end

  def should_highlight?
    false
  end

  def name(_ = false)
    tournament_day.scoring_rules.each do |rule|
      overridden_name = rule.override_scorecard_name(scorecard: self)

      return overridden_name if overridden_name.present?
    end

    golf_outing.user.short_name
  end

  def individual_name
    golf_outing.user.complete_name
  end

  def matchup_position_indicator
    matchup = tournament_day.league_season_team_matchup_for_player(user)

    matchup.matchup_indicator_for_user(user) if matchup.present?
  end

  # Customization

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
    tournament_day.scorecard_base_scoring_rule.includes_extra_scoring_column?
  end

  def extra_scoring_column_data
    nil
  end
end
