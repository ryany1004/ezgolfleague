class TournamentDay < ApplicationRecord
  include Moveable
  include FindPlayers
  include Servable

  include CacheKeyable

  include ::AddToTournamentDay
  include ::RemoveFromTournamentDay
  include ::CourseHandicapTournamentDay
  include ::FlightTournamentDay
  include ::Autoschedule
  include ::TournamentApiSupport
  include ::TournamentScorecardSupport

  belongs_to :tournament, inverse_of: :tournament_days, touch: true, counter_cache: true
  belongs_to :course, inverse_of: :tournament_days
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament_day, dependent: :destroy
  has_many :flights, -> { order(:flight_number) }, inverse_of: :tournament_day, dependent: :destroy
  has_many :contests, -> { order(:name) }, inverse_of: :tournament_day, dependent: :destroy
  has_many :scoring_rules, inverse_of: :tournament_day, dependent: :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }

  attr_accessor :skip_date_validation

  after_create :create_default_flight, if: :is_first_day?

  # #TEAM - MOVE ALL OF THESE
  # delegate :player_points, :player_payouts, :flights_with_rankings, :assign_payouts_from_scores, to: :game_type
  # delegate :allow_teams, :show_teams?, :players_create_teams?, :show_team_scores_for_all_teammates?, to: :game_type
  # ##END MOVE

  validates :course, presence: true
  validates :tournament_at, presence: true
  validates :tournament_at, uniqueness: { scope: :tournament }

  validate :dates_are_valid, on: :create, unless: -> { self.skip_date_validation }
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day

    if tournament_at.present? && tournament_at < now
      errors.add(:tournament_at, "can't be in the past")
    end
  end

  #TEAM: REMOVE
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
    elsif self.game_type_id == 14
      new_game_type = GameTypes::TwoManIndividualStrokePlay.new
    else
      new_game_type = GameTypes::IndividualStrokePlay.new ##### REMOVE
    end

    new_game_type&.tournament_day = self

    new_game_type
  end

  def can_be_finalized?
    self.scoring_rules.each do |r|
      if r.can_be_finalized? == false
        return false
      end
    end

    true
  end

  def can_be_played?
    self.scoring_rules.each do |r|
      if r.can_be_played? == false
        return false
      end
    end

    #has at least one non-optional rule
    return false if self.mandatory_scoring_rules.count == 0

    true
  end

  def is_first_day?
    self.tournament.first_day == self
  end

  def pretty_day(add_space = false)
    return "Day 1" if self.tournament.tournament_days.count == 1

    day_index = 0

    self.tournament.tournament_days.each_with_index do |d, i|
      day_index = i if d == self
    end

    day_string = "Day #{day_index + 1}"
    day_string = day_string + " " if add_space == true

    day_string
  end

  #TODO: MOVE
  def create_default_flight
    if self.tournament.league.allow_scoring_groups
      self.create_scoring_group_flights
    else
      self.create_traditional_flight
    end
  end

  #TODO: MOVE
  def create_traditional_flight
    Flight.create(tournament_day: self, flight_number: 1, lower_bound: 0, upper_bound: 300, course_tee_box: self.course.course_tee_boxes.first)
  end

  #TODO: MOVE
  def create_scoring_group_flights
    self.tournament.league_season.league_season_scoring_groups.each_with_index do |g, i|
      f = Flight.new(tournament_day: self, flight_number: i + 1, lower_bound: 0, upper_bound: 0, course_tee_box: self.course.course_tee_boxes.first, league_season_scoring_group: g)

      f.save(:validate => false)
    end
  end

  #TODO: MOVE
  def copy_flights_from_previous_day
    self.tournament.first_day.flights.each do |f|
      Flight.create(tournament_day: self, flight_number: f.flight_number, lower_bound: f.lower_bound, upper_bound: f.upper_bound, course_tee_box: f.course_tee_box)
    end
  end

  def eager_groups
    TournamentGroup.includes(golf_outings: [:user, course_tee_box: :course_hole_tee_boxes, scorecard: [{scores: :course_hole}]]).where(tournament_day: self)
  end

  def flights_with_rankings
    self.flights.includes(:users, :tournament_day_results, :payout_results)
  end

  #TODO: MOVE
  def scorecard_display_partial
    if self.course_holes.count <= 9
      '/shared/scorecards/nine_hole'
    else
      '/shared/scorecards/standard'
    end
  end

  def scorecard_print_partial
    if self.course_holes.count <= 9
      '/shared/scorecards/nine_hole_print'
    else
      '/shared/scorecards/print'
    end
  end
  #TODO: MOVE

  def has_scores?
    self.eager_groups.each do |group|
      group.golf_outings.each do |golf_outing|
        golf_outing.scorecard.scores.each do |score|
          return true if score.strokes > 0
        end
      end
    end

    false
  end

  def has_payouts?
    self.flights.each do |flight|
      return true if flight.payouts.count > 0
    end

    false
  end

  def needs_daily_teams?
    self.users_per_daily_teams > 0
  end

  def users_per_daily_teams
    users_per = 0

    self.scoring_rules.each do |rule|
      users_per = rule.users_per_daily_team if rule.users_per_daily_team > 1
    end

    users_per
  end

  def daily_teams
    flattened_teams = self.tournament_groups.collect(&:daily_teams).flatten!
    if flattened_teams.present?
      flattened_teams
    else
      []
    end
  end

  def mandatory_scoring_rules
    self.scoring_rules.where(is_opt_in: false)
  end

  def score_all_rules
    self.scoring_rules.each do |rule|
      rule.score
      rule.rank
    end
  end

  def assign_payouts_all_rules
    self.scoring_rules.each do |rule|
      rule.assign_payouts
    end
  end

  def handicap_allowance(user:)
    handicap_computer = self.mandatory_scoring_rules.first.handicap_computer

    handicap_computer.handicap_allowance(user: user)
  end

  def paid_contests
    self.contests.where("dues_amount > 0")
  end

  #TODO: move, API support

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
