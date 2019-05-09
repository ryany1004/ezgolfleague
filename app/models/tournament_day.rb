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

  validate :dates_are_valid, on: :create, unless: -> { self.skip_date_validation }
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day

    if tournament_at.present? && tournament_at < now
      errors.add(:tournament_at, "can't be in the past")
    end
  end

  def can_be_finalized?
    self.scoring_rules.each do |r|
      if !r.can_be_finalized?
        return false
      end
    end

    true
  end

  def finalization_blockers
    blockers = []

    self.scoring_rules.each do |r|
      blockers += r.finalization_blockers
    end

    blockers
  end

  def can_be_played?
  	return false if self.mandatory_scoring_rules.count.zero?
  	return false if self.scorecard_base_scoring_rule.blank?

    self.scoring_rules.each do |r|
      if !r.can_be_played?
        return false
      end
    end

    true
  end

  def is_first_day?
    self.tournament.first_day == self
  end

  def pretty_day(add_space = false)
    if self.tournament.tournament_days.count == 1
    	day_string = "Day 1"
    else
	    day_index = 0

	    self.tournament.tournament_days.each_with_index do |d, i|
	      day_index = i if d == self
	    end

	    day_string = "Day #{day_index + 1}"
    end

    day_string = day_string + " " if add_space

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
    @eager_groups ||= TournamentGroup.includes(golf_outings: [:user, course_tee_box: :course_hole_tee_boxes, scorecard: [{scores: :course_hole}]]).where(tournament_day: self)
  end

  def flights_with_rankings
    @flights_with_rankings ||= self.flights.includes(:users, :tournament_day_results, :payout_results)
  end

  def golf_outings
    @golf_outings ||= self.tournament_groups.map(&:golf_outings).flatten
  end

  #TODO: MOVE
  def scorecard_display_partial
    if self.scorecard_base_scoring_rule.course_holes.count <= 9
      '/shared/scorecards/nine_hole'
    else
      '/shared/scorecards/standard'
    end
  end

  def scorecard_print_partial
    if self.scorecard_base_scoring_rule.course_holes.count <= 9
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

  def create_league_season_team_matchups
    if self.tournament.league_season.is_teams?
      number_of_teams = self.tournament.league_season.league_season_teams.size
      number_of_matchups = (number_of_teams.to_f / 2.0).ceil #round up
      number_of_matchups -= self.league_season_team_tournament_day_matchups.count

      number_of_matchups.times.each_with_index do |item, i|
        LeagueSeasonTeamTournamentDayMatchup.create(tournament_day: self)
      end
    end
  end

  def tournament_group_with_open_slots(required_slots)
    self.tournament_groups.each do |group|
      open_slots = group.max_number_of_players - group.golf_outings.count

      if open_slots >= required_slots
        return group
      else
        next
      end
    end

    return nil
  end

  def add_league_season_team(league_season_team, matchup, slot_id)
    if slot_id == "0"
      matchup.team_a = league_season_team
    elsif slot_id == "1"
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

  def strip_to_front_9
    self.tournament_groups.each do |g|
      g.golf_outings.each do |o|
        o.scorecard.scores.each_with_index do |s, i|
          s.destroy if i > 8
        end
      end
    end
  end

  def scorecard_base_scoring_rule
    @scorecard_base_scoring_rule ||= self.scoring_rules.where(primary_rule: true).first
  end

  def mandatory_scoring_rules
    @mandatory_scoring_rules ||= self.scoring_rules.where(is_opt_in: false).order(:type)
  end

  def mandatory_individual_scoring_rules
    @mandatory_individual_scoring_rules ||= self.mandatory_scoring_rules.select { |r| r.team_type != ScoringRuleTeamType::LEAGUE }
  end

  def mandatory_team_scoring_rules
    @mandatory_team_scoring_rules ||= self.mandatory_scoring_rules.select { |r| r.team_type == ScoringRuleTeamType::LEAGUE }
  end

  def optional_scoring_rules
    @optional_scoring_rules ||= self.scoring_rules.where(is_opt_in: true).order(:type)
  end

  def optional_scoring_rules_with_dues
    @optional_scoring_rules_with_dues ||= self.optional_scoring_rules.select { |r| r.dues_amount > 0 }
  end

  def legacy_game_type_id
  	if self.mandatory_scoring_rules.first.present?
  		self.mandatory_scoring_rules.first.legacy_game_type_id
  	else
  		-1
  	end
  end

  def score_all_rules(delete_first: false)
    self.scoring_rules.each do |rule|
    	rule.tournament_day_results.delete_all if delete_first

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
    handicap_computer = self.scorecard_base_scoring_rule.handicap_computer

    handicap_computer.displayable_handicap_allowance(user: user)
  end

  #date parsing
  def tournament_at=(date)
    begin
      parsed = EzglCalendar::CalendarUtils.datetime_for_picker_date(date)
      super parsed
    rescue
      write_attribute(:tournament_at, date)
    end
  end

end
