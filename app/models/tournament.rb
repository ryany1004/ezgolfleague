module AutoScheduleType
  MANUAL = 0
  AUTOMATIC_WORST_FIRST = 1
  AUTOMATIC_BEST_FIRST = 2
end

class Tournament < ApplicationRecord
  include Playable
  include Rankable
  include Servable

  extend FinderSupport

  belongs_to :league, inverse_of: :tournaments
  has_many :tournament_days, -> { order(:tournament_at) }, inverse_of: :tournament, dependent: :destroy
  has_many :notification_templates, dependent: :destroy

  accepts_nested_attributes_for :tournament_days

  attr_accessor :optional_game_types
  attr_accessor :another_member_id
  attr_accessor :skip_date_validation

  around_destroy :recalculate_standings_for_destroy

  validates :name, presence: true
  validates :league, presence: true
  validates :signup_opens_at, presence: true
  validates :signup_closes_at, presence: true
  validates :max_players, presence: true
  validates :max_players, numericality: { greater_than_or_equal_to: 0 }

  validate :dates_are_valid, on: :create, unless: :is_super_user_setup?
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day

    if signup_opens_at.present? && signup_opens_at < now
      errors.add(:signup_opens_at, "can't be in the past")
    end

    if signup_closes_at.present? && signup_closes_at < now
      errors.add(:signup_closes_at, "can't be in the past")
    end

    unless !self.has_tournament_days?
      if signup_opens_at.present? && self.first_day.tournament_at.present? && self.first_day.tournament_at < signup_opens_at
        errors.add(:signup_opens_at, "can't be after the tournament")
      end
    end

    if signup_opens_at.present? && signup_closes_at.present? && signup_opens_at > signup_closes_at
      errors.add(:signup_closes_at, "can't be before the sign up opening")
    end
  end

  def is_super_user_setup?
    self.skip_date_validation
  end

  validate :league_has_season
  def league_has_season
    if self.signup_closes_at.blank?
      errors.add(:signup_closes_at, "must be present.")
    else
    	seasons = self.league.league_seasons.where("ends_at >= ?", self.signup_closes_at)

      if seasons.blank?
        errors.add(:signup_closes_at, "can't be outside your configured league seasons.")
      end
    end
  end

  paginates_per 20

  def recalculate_standings_for_destroy
    season = self.league_season

    yield

    RankLeagueSeasonJob.perform_later(season)
  end

  def league_season
    return nil if !self.has_tournament_days?

    self.league.league_seasons.each do |s|
      if self.first_day.tournament_at >= s.starts_at && self.first_day.tournament_at < s.ends_at
        return s
      end
    end

    nil
  end

  def is_league_teams?
    self.league_season.is_teams?
  end

  def season_name
    season = self.league_season

    unless season.blank?
      season.name
    else
      "?"
    end
  end

  def first_day
    self.tournament_days.first
  end

  def last_day
    self.tournament_days.last
  end

  def has_tournament_days?
    self.tournament_days.count > 0
  end

  def has_league_season_team_scoring_rules?
    tournament_days.each do |d|
      return true if d.scoring_rules.any? { |x| x.team_type == ScoringRuleTeamType::LEAGUE }
    end

    false
  end

  def previous_day_for_day(day)
    index_for_day = self.tournament_days.index(day)
    unless index_for_day.blank?
      if self.tournament_days.count >= (index_for_day - 1)
        self.tournament_days[index_for_day - 1]
      else
        nil
      end
    else
      nil
    end
  end

  def finalization_notifications
    self.notification_templates.where("tournament_notification_action = ?", "On Finalization")
  end

  def notify_tournament_users(notification_string, extra_data)
    self.players.each do |u|
      u.send_mobile_notification(notification_string, { tournament_id: self.id })
    end
  end

  def mandatory_dues_amount
    dues_amount = 0.0

    self.tournament_days.each do |day|
      day.mandatory_scoring_rules.each do |rule|
        dues_amount += rule.dues_amount
      end
    end

    dues_amount
  end

  def dues_for_user(user, include_credit_card_fees = false)
    membership = user.league_memberships.where("league_id = ?", self.league.id).first

    if membership.present?
      dues_amount = self.mandatory_dues_amount

      credit_card_fees = 0
      credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(dues_amount) if include_credit_card_fees == true

      total = dues_amount + credit_card_fees

      total
    else
      0
    end
  end

  def total_for_user_with_optional_fees(user:, include_credit_card_fees: true)
    dues_amount = self.mandatory_dues_amount

    self.optional_scoring_rules_with_dues.each do |r|
      if r.users.include? user
        dues_amount += r.dues_amount
      end
    end

    credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(dues_amount)

    total = dues_amount + credit_card_fees

    total
  end

  def cost_breakdown_for_user(user:, include_unpaid_optional_rules: true, include_credit_card_fees: true)
    dues_total = self.mandatory_dues_amount

    cost_lines = [
      {name: "#{self.name} Fees", price: self.mandatory_dues_amount.to_f, server_id: self.id.to_s}
    ]

    if include_unpaid_optional_rules
      self.optional_scoring_rules_with_dues.each do |r|
        if r.users.include? user
          cost_lines += r.cost_breakdown_for_user(user: user, include_credit_card_fees: false)

          dues_total += r.dues_amount
        end
      end
    end

    if include_credit_card_fees
      cost_lines << {name: "Credit Card Fees", price: Stripe::StripeFees.fees_for_transaction_amount(dues_total)}
    end

    cost_lines
  end

  def courses
    distinct_courses = []

    self.tournament_days.each do |day|
      distinct_courses << day.course unless distinct_courses.include? day.course
    end

    distinct_courses
  end

  def mandatory_scoring_rules
    @mandatory_scoring_rules ||= self.tournament_days.map(&:mandatory_scoring_rules).flatten
  end

  def mandatory_individual_scoring_rules
    @mandatory_individual_scoring_rules ||= self.tournament_days.map(&:mandatory_individual_scoring_rules).flatten
  end

  def mandatory_team_scoring_rules
    @mandatory_team_scoring_rules ||= self.tournament_days.map(&:mandatory_team_scoring_rules).flatten
  end

  def optional_scoring_rules
    @optional_scoring_rules ||= self.tournament_days.map(&:optional_scoring_rules).flatten
  end

  def optional_scoring_rules_with_dues
    @optional_scoring_rules_with_dues ||= self.tournament_days.map(&:optional_scoring_rules_with_dues).flatten
  end

  def is_paid?
    if self.league.exempt_from_subscription
      true
    else
      false # TODO: Update this to check for subscription or remove this and use other methods.
    end
  end

  def all_days_are_playable?
    return false if self.tournament_days.count == 0

    playable = true

    self.tournament_days.each do |d|
      playable = false if !d.can_be_played?
    end

    playable
  end

  def any_days_are_playable?
    playable = false

    self.tournament_days.each do |d|
      return true if d.can_be_played?
    end

    playable
  end

  def sum_player_scores_for_multi_day?
    sum_scores = true

    self.tournament_days.each do |d|
      if d != self.tournament_days.last
        d.flights.each do |f|
          sum_scores = false if f.payouts.count > 0
        end
      end
    end

    sum_scores
  end

  def can_be_finalized?
    return false if self.last_day.blank?
    return false if self.last_day.scoring_rules.count == 0

    self.last_day.can_be_finalized?
  end

  def finalization_blockers
    blockers = []

    self.tournament_days.each do |d|
      blockers += d.finalization_blockers
    end

    blockers
  end

  def is_past?
    return false if self.first_day.blank?

    if self.last_day.tournament_at > DateTime.yesterday
      false
    else
      true
    end
  end

  def is_open_for_registration?
    return false if self.number_of_players >= self.max_players
    return false if self.signup_opens_at > Time.zone.now
    return false if self.signup_closes_at < Time.zone.now

    unplayable_days = false
    self.tournament_days.each do |day|
      unplayable_days = true if day.can_be_played? == false
    end
    return false if unplayable_days == true

    true
  end

  def update_course_handicaps
    self.tournament_days.each do |day|
      day.tournament_groups.each do |group|
        group.golf_outings.each do |outing|
          outing.scorecard.set_course_handicap(true)
        end
      end
    end
  end

  def user_has_paid?(user)
    tournament_balance = 0.0

    scoring_rule_ids = self.tournament_days.map(&:scoring_rules).flatten.map(&:id)
    payments = Payment.where(scoring_rule: scoring_rule_ids).where(user: user).where('payment_amount > 0')
    tournament_balance = payments.sum(:payment_amount)

    if tournament_balance > 0 && tournament_balance >= self.dues_for_user(user)
      true
    else
      false
    end
  end

  # date parsing
  
  def signup_opens_at=(date)
    begin
      parsed = EzglCalendar::CalendarUtils.datetime_for_picker_date(date)
      super parsed
    rescue
      write_attribute(:signup_opens_at, date)
    end
  end

  def signup_closes_at=(date)
    begin
      parsed = EzglCalendar::CalendarUtils.datetime_for_picker_date(date)
      super parsed
    rescue
      write_attribute(:signup_closes_at, date)
    end
  end

end
