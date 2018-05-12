class TournamentDay < ApplicationRecord
  include Addable
  include Moveable
  include Scoreable
  include FindPlayers
  include AutoSchedulable
  include Servable

  belongs_to :tournament, inverse_of: :tournament_days, touch: true, counter_cache: true
  belongs_to :course, inverse_of: :tournament_days
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :flights, -> { order(:flight_number) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :contests, -> { order(:name) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :golfer_teams, inverse_of: :tournament_day, :dependent => :destroy
  has_many :tournament_day_results, -> { order(:flight_id, :net_score) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :payout_results, inverse_of: :tournament_day, :dependent => :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }

  attr_accessor :skip_date_validation

  after_create :create_default_flight

  delegate :player_score, :compute_player_score, :compute_stroke_play_player_score, :compute_adjusted_player_score, :player_points, :player_payouts, :flights_with_rankings, :related_scorecards_for_user, :assign_payouts_from_scores, to: :game_type
  delegate :allow_teams, :show_teams?, :players_create_teams?, :show_team_scores_for_all_teammates?, to: :game_type
  delegate :scorecard_payload_for_scorecard, to: :game_type
  delegate :other_group_members, :user_is_in_group?, to: :game_type
  delegate :handicap_allowance, to: :game_type
  delegate :can_be_played?, :can_be_finalized?, to: :game_type

  validates :course, presence: true
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

  def create_default_flight
    if self.tournament.league.allow_scoring_groups
      self.create_scoring_group_flights
    else
      self.create_traditional_flight
    end
  end

  def create_traditional_flight
    Flight.create(tournament_day: self, flight_number: 1, lower_bound: 0, upper_bound: 300, course_tee_box: self.course.course_tee_boxes.first)
  end

  def create_scoring_group_flights
    self.tournament.league_season.league_season_scoring_groups.each_with_index do |g, i|
      f = Flight.new(tournament_day: self, flight_number: i + 1, lower_bound: 0, upper_bound: 0, course_tee_box: self.course.course_tee_boxes.first, league_season_scoring_group: g)

      f.save(:validate => false)
    end
  end

  def eager_groups
    TournamentGroup.includes(golf_outings: [:user, course_tee_box: :course_hole_tee_boxes, scorecard: [{scores: :course_hole}]]).where(tournament_day: self)
  end

  def tournament_day_results_cache_key(prefix)
    max_updated_at = self.tournament_day_results.maximum(:updated_at).try(:utc).try(:to_s, :number)
    cache_key = "tournament_days/#{prefix}-#{self.id}-#{max_updated_at}"

    return cache_key
  end

  def groups_api_cache_key
    return "groups-json#{self.id}-#{self.updated_at.to_i}"
  end

  def leaderboard_api_cache_key
    return "leaderboard-json#{self.id}-#{self.updated_at.to_i}"
  end

  def flights_with_rankings_cache_key
    return "flightswithrankings-json#{self.id}-#{self.updated_at.to_i}"
  end

  def scorecard_print_cache_key
    return "print-scorecards#{self.id}-#{self.updated_at.to_i}"
  end

  def scorecard_display_partial
    if self.course_holes.count <= 9
      "/shared/scorecards/nine_hole"
    else
      "/shared/scorecards/standard"
    end
  end

  def scorecard_print_partial
    if self.course_holes.count <= 9
      "/shared/scorecards/nine_hole_print"
    else
      "/shared/scorecards/print"
    end
  end

  def has_payouts?
    self.flights.each do |flight|
      return true if flight.payouts.count > 0
    end

    return false
  end

  def registered_user_ids
    cache_key = "registereduserids-json#{self.id}-#{self.updated_at.to_i}"
    user_ids = []

    user_ids = Rails.cache.fetch(cache_key, expires_in: 5.minute, race_condition_ttl: 10) do
      self.tournament.players_for_day(self).each do |player|
        user_ids << player.id.to_s unless player.blank?
      end

      user_ids
    end

    user_ids
  end

  def paid_user_ids
    cache_key = "paiduserids-json#{self.id}-#{self.updated_at.to_i}"
    user_ids = []

    user_ids = Rails.cache.fetch(cache_key, expires_in: 5.minute, race_condition_ttl: 10) do
      self.tournament.players_for_day(self).each do |player|
        user_ids << player.id.to_s if self.tournament.user_has_paid?(player)
      end

      user_ids
    end

    user_ids
  end

  def superuser_user_ids
    user_ids = []

    self.tournament.players_for_day(self).each do |player|
      user_ids << player.id.to_s if player.is_super_user
    end

    return user_ids
  end

  def league_admin_user_ids
    user_ids = []

    self.tournament.league.league_admins.each do |user|
      user_ids << user.id.to_s
    end

    return user_ids
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
