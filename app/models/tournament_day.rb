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
  has_many :scoring_rules, -> { order(primary_rule: :desc) }, inverse_of: :tournament_day, dependent: :destroy
  has_many :league_season_team_tournament_day_matchups, -> { order(:created_at) }, inverse_of: :tournament_day, dependent: :destroy

  accepts_nested_attributes_for :scoring_rules

  attr_accessor :skip_date_validation

  after_create :create_default_flight, if: :is_first_day?
  after_create :create_league_season_team_matchups

  validates :course, presence: true
  validates :tournament_at, presence: true
  validates :tournament_at, uniqueness: { scope: :tournament }

  validate :dates_are_valid, on: :create, unless: -> { skip_date_validation }
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day

    errors.add(:tournament_at, "can't be in the past") if tournament_at.present? && tournament_at < now
  end

  def can_be_finalized?
    displayable_scoring_rules.each do |r|
      if !r.can_be_finalized?
        return false
      end
    end

    true
  end

  def finalization_blockers
    blockers = []

    scoring_rules.each do |r|
      blockers += r.finalization_blockers
    end

    blockers
  end

  def can_be_played?
    return false if mandatory_scoring_rules.count.zero?
    return false if scorecard_base_scoring_rule.blank?

    scoring_rules.each do |r|
      return false unless r.can_be_played?
    end

    true
  end

  def is_first_day?
    tournament.first_day == self
  end

  def pretty_day(add_space = false)
    if tournament.tournament_days.count == 1
      day_string = 'Day 1'
    else
      day_index = 0

      tournament.tournament_days.each_with_index do |d, i|
        day_index = i if d == self
      end

      day_string = "Day #{day_index + 1}"
    end

    day_string += ' ' if add_space

    day_string
  end

  # TODO: MOVE
  def create_default_flight
    if tournament.league.allow_scoring_groups
      create_scoring_group_flights
    else
      create_traditional_flight
    end
  end

  # TODO: MOVE
  def create_traditional_flight
    Flight.create(tournament_day: self, flight_number: 1, lower_bound: 0, upper_bound: 300, course_tee_box: course.course_tee_boxes.first)
  end

  # TODO: MOVE
  def create_scoring_group_flights
    tournament.league_season.league_season_scoring_groups.each_with_index do |g, i|
      f = Flight.new(tournament_day: self, flight_number: i + 1, lower_bound: 0, upper_bound: 0, course_tee_box: course.course_tee_boxes.first, league_season_scoring_group: g)

      f.save(validate: false)
    end
  end

  # TODO: MOVE
  def copy_flights_from_previous_day
    tournament.first_day.flights.each do |f|
      Flight.create(tournament_day: self, flight_number: f.flight_number, lower_bound: f.lower_bound, upper_bound: f.upper_bound, course_tee_box: f.course_tee_box)
    end
  end

  def eager_groups
    @eager_groups ||= TournamentGroup.includes(golf_outings: [:user, course_tee_box: :course_hole_tee_boxes, scorecard: [{ scores: :course_hole }]]).where(tournament_day: self)
  end

  def flights_with_rankings
    @flights_with_rankings ||= flights.includes(:users, :tournament_day_results, :payout_results)
  end

  def primary_scoring_rule_flights_with_rankings
    group_results_by_flight(scorecard_base_scoring_rule.tournament_day_results)
  end

  def stroke_play_flights_with_rankings
    group_results_by_flight(stroke_play_scoring_rule.tournament_day_results)
  end

  def group_results_by_flight(results)
    flights = []

    last_flight_id = nil
    current_flight_contents = []

    results.each do |r|
      last_flight_id = r.flight_id if last_flight_id.blank?

      if r.flight_id != last_flight_id
        flights << current_flight_contents
        current_flight_contents = []

        last_flight_id = r.flight_id
      end

      current_flight_contents << r
    end

    flights << current_flight_contents
    flights
  end

  def golf_outings
    @golf_outings ||= tournament_groups.map(&:golf_outings).flatten
  end

  # TODO: MOVE
  def scorecard_display_partial
    if scorecard_base_scoring_rule.course_holes.count <= 9
      '/shared/scorecards/nine_hole'
    else
      '/shared/scorecards/standard'
    end
  end

  def scorecard_print_partial
    if scorecard_base_scoring_rule.course_holes.count <= 9
      '/shared/scorecards/nine_hole_print'
    else
      '/shared/scorecards/print'
    end
  end
  # TODO: MOVE

  def has_scores?
    eager_groups.each do |group|
      group.golf_outings.each do |golf_outing|
        golf_outing.scorecard.scores.each do |score|
          return true if score.strokes.positive?
        end
      end
    end

    false
  end

  def has_payouts?
    flights.each do |flight|
      return true if flight.payouts.count.positive?
    end

    false
  end

  def needs_daily_teams?
    users_per_daily_teams > 0
  end

  def users_per_daily_teams
    users_per = 0

    scoring_rules.each do |rule|
      users_per = rule.users_per_daily_team if rule.users_per_daily_team > 1 && rule.users_per_daily_team > users_per
    end

    users_per
  end

  def daily_teams
    flattened_teams = tournament_groups.collect(&:daily_teams).flatten!
    if flattened_teams.present?
      flattened_teams
    else
      []
    end
  end

  def create_league_season_team_matchups
    if tournament.league_season.is_teams?
      number_of_teams = tournament.league_season.league_season_teams.size
      number_of_matchups = (number_of_teams.to_f / 2.0).ceil # round up
      number_of_matchups -= league_season_team_tournament_day_matchups.count

      number_of_matchups.times.each_with_index do |_, _|
        LeagueSeasonTeamTournamentDayMatchup.create(tournament_day: self)
      end
    end
  end

  def tournament_group_with_open_slots(required_slots)
    tournament_groups.each do |group|
      open_slots = group.max_number_of_players - group.golf_outings.count

      if open_slots >= required_slots
        return group
      else
        next
      end
    end

    nil
  end

  def add_league_season_team(league_season_team, matchup, slot_id)
    if slot_id == '0'
      matchup.team_a = league_season_team
    elsif slot_id == '1'
      matchup.team_b = league_season_team
    end

    matchup.save
  end

  def remove_league_season_team(matchup, league_season_team)
    matchup.team_a = nil if league_season_team == matchup.team_a
    matchup.team_b = nil if league_season_team == matchup.team_b
    matchup.winning_team = nil
    matchup.save
  end

  def scorecard_base_scoring_rule
    @scorecard_base_scoring_rule ||= scoring_rules.find_by(primary_rule: true)
  end

  def base_is_stroke_play?
    scorecard_base_scoring_rule&.instance_of?(StrokePlayScoringRule)
  end

  def stroke_play_scoring_rule
    if base_is_stroke_play?
      scorecard_base_scoring_rule
    else
      rule = scoring_rules.find_by(base_stroke_play: true)
      rule.presence || scorecard_base_scoring_rule
    end
  end

  def displayable_scoring_rules
    @displayable_scoring_rules ||= scoring_rules.where(base_stroke_play: false)
  end

  def scorecard_non_base_scoring_rule
    @scorecard_non_base_scoring_rule ||= scoring_rules.find_by(primary_rule: false, base_stroke_play: false)
  end

  def mandatory_scoring_rules
    @mandatory_scoring_rules ||= scoring_rules.where(is_opt_in: false).order(:type)
  end

  def mandatory_individual_scoring_rules
    @mandatory_individual_scoring_rules ||= mandatory_scoring_rules.reject { |r| r.team_type == ScoringRuleTeamType::LEAGUE }
  end

  def mandatory_team_scoring_rules
    @mandatory_team_scoring_rules ||= mandatory_scoring_rules.select { |r| r.team_type == ScoringRuleTeamType::LEAGUE }
  end

  def optional_scoring_rules
    @optional_scoring_rules ||= scoring_rules.where(is_opt_in: true).order(:type)
  end

  def optional_scoring_rules_with_dues
    @optional_scoring_rules_with_dues ||= optional_scoring_rules.select { |r| r.dues_amount.positive? }
  end

  def points_for_user(user:)
    scoring_rules.map { |rule| rule.points_for_user(user: user) }.sum
  end

  def scoring_rules_for_user(user:)
    scoring_rules.map { |rule| rule.users.include? user }
  end

  def legacy_game_type_id
    if mandatory_scoring_rules.first.present?
      mandatory_scoring_rules.first.legacy_game_type_id
    else
      -1
    end
  end

  def score_all_rules(delete_first: false)
    scoring_rules.each do |rule|
      rule.tournament_day_results.delete_all if delete_first

      rule.score
      rule.rank
    end
  end

  def assign_payouts_all_rules
    scoring_rules.each(&:assign_payouts)
  end

  def handicap_allowance(user:)
    handicap_computer = scorecard_base_scoring_rule.handicap_computer

    handicap_computer.displayable_handicap_allowance(user: user)
  end

  # # date parsing
  # def tournament_at=(date)
  #   begin
  #     parsed = EzglCalendar::CalendarUtils.datetime_for_picker_date(date)
  #     super parsed
  #   rescue
  #     write_attribute(:tournament_at, date)
  #   end
  # end
end
