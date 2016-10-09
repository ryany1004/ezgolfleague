class TournamentDay < ActiveRecord::Base
  include Addable
  include Moveable
  include Scoreable
  include FindPlayers
  include AutoSchedulable
  include Servable

  belongs_to :tournament, inverse_of: :tournament_days, :touch => true, counter_cache: true
  belongs_to :course, inverse_of: :tournament_days
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :flights, -> { order(:flight_number) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :contests, inverse_of: :tournament_day, :dependent => :destroy
  has_many :golfer_teams, inverse_of: :tournament_day, :dependent => :destroy
  has_many :tournament_day_results, -> { order(:flight_id, :net_score) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :payout_results, inverse_of: :tournament_day, :dependent => :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }

  attr_accessor :skip_date_validation

  delegate :player_score, :compute_player_score, :compute_stroke_play_player_score, :compute_adjusted_player_score, :player_points, :flights_with_rankings, :related_scorecards_for_user, :assign_payouts_from_scores, to: :game_type
  delegate :allow_teams, :show_teams?, :players_create_teams?, :show_team_scores_for_all_teammates?, to: :game_type
  delegate :scorecard_payload_for_scorecard, to: :game_type
  delegate :other_group_members, :user_is_in_group?, to: :game_type
  delegate :handicap_allowance, to: :game_type
  delegate :can_be_played?, :can_be_finalized?, to: :game_type

  validates :tournament_at, presence: true
  validates :tournament_at, uniqueness: { scope: :tournament }

  validate :dates_are_valid, on: :create, unless: "self.skip_date_validation == true"
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day

    if tournament_at.present? && tournament_at < now
      errors.add(:tournament_at, "can't be in the past")
    end
  end

  def game_type
    if self.game_type_id == 1
      new_game_type = GameTypes::IndividualStrokePlay.new
    elsif self.game_type_id == 2
      new_game_type = GameTypes::IndividualMatchPlay.new
    elsif self.game_type_id == 3
      new_game_type = GameTypes::IndividualModifiedStableford.new
    elsif self.game_type_id == 5
      new_game_type = GameTypes::TwoManShamble.new
    elsif self.game_type_id == 7
      new_game_type = GameTypes::TwoManScramble.new
    elsif self.game_type_id == 8
      new_game_type = GameTypes::FourManScramble.new
    elsif self.game_type_id == 10
      new_game_type = GameTypes::TwoManBestBall.new
    elsif self.game_type_id == 11
      new_game_type = GameTypes::TwoBestBallsOfFour.new
    elsif self.game_type_id == 12
      new_game_type = GameTypes::TwoManComboScrambleBestBall.new
    elsif self.game_type_id == 13
      new_game_type = GameTypes::OneTwoThreeBestBallsOfFour.new
    end

    new_game_type.tournament_day = self

    return new_game_type
  end

  def pretty_day(add_space = false)
    return nil if self.tournament.tournament_days.count == 1

    day_index = 0

    self.tournament.tournament_days.each_with_index do |d, i|
      day_index = i if d == self
    end

    day_string = "Day #{day_index + 1}"
    day_string = day_string + " " if add_space == true

    return day_string
  end

  def tournament_day_results_cache_key(prefix)
    max_updated_at = self.tournament_day_results.maximum(:updated_at).try(:utc).try(:to_s, :number)
    cache_key = "tournament_days/#{prefix}-#{self.id}-#{max_updated_at}"

    return cache_key
  end

  def groups_api_cache_key
    return "groups-json#{self.id}-#{self.updated_at.to_s}"
  end

  def leaderboard_api_cache_key
    return "leaderboard-json#{self.id}-#{self.updated_at.to_s}"
  end

  def flights_with_rankings_cache_key
    return "flightswithrankings-json#{self.id}-#{self.updated_at.to_s}"
  end

  def scorecard_print_cache_key
    return "print-scorecards#{self.id}-#{self.updated_at.to_s}"
  end

  def has_payouts?
    self.flights.each do |flight|
      return true if flight.payouts.count > 0
    end

    return false
  end

  def registered_user_ids
    user_ids = []

    self.tournament.players_for_day(self).each do |player|
      user_ids << player.id.to_s unless player.blank?
    end

    return user_ids
  end

  def paid_user_ids
    user_ids = []

    self.tournament.players_for_day(self).each do |player|
      user_ids << player.id.to_s if self.tournament.user_has_paid?(player)
    end

    return user_ids
  end

  def superuser_user_ids
    user_ids = []

    self.tournament.players_for_day(self).each do |player|
      user_ids << player.id.to_s if player.is_super_user
    end

    return user_ids
  end

  #are you sure you really want to do this?!?
  def clear_scores
    self.tournament_groups.each do |group|
      group.golf_outings.each do |outing|
        outing.scorecard.scores.each do |score|
          score.strokes = 0
          score.save
        end
      end
    end

    self.tournament_day_results.destroy_all
  end

  def recreate_scorecards
    self.course_holes.destroy_all

    self.course.course_holes.each do |ch|
      self.course_holes << ch
    end

    self.tournament_groups.each do |g|
      g.golf_outings.each do |out|
        out.scorecard.destroy

        scorecard = Scorecard.create!(golf_outing: out)

        self.assign_players_to_flights
        flight = self.flight_for_player(out.user)

        self.course_holes.each_with_index do |hole, i|
          score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
        end
      end
    end
  end

  #date parsing
  def tournament_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:tournament_at, date)
    end
  end

end
