module ScoringRuleTeamType
  NONE = 1
  LEAGUE = 2
  DAILY = 3
end

module ScoringRulePayoutType
  PREDETERMINED = 1
  POT = 2
end

module ScoringRulePayoutAssignmentType
  CALCULATED = 1
  MANUAL = 2
end

class ScoringRule < ApplicationRecord
  include Servable

  belongs_to :tournament_day, touch: true, inverse_of: :scoring_rules
  has_many :payments, inverse_of: :scoring_rule, dependent: :destroy
  has_many :payouts, -> { order(:sort_order, 'amount DESC, points DESC') }, inverse_of: :scoring_rule, dependent: :destroy
  has_many :payout_results, -> { order(:flight_id, amount: :desc, points: :desc) }, inverse_of: :scoring_rule, dependent: :destroy
  has_many :tournament_day_results, -> { order(:flight_id, :sort_rank) }, inverse_of: :scoring_rule, dependent: :destroy
  has_many :scoring_rule_participations, dependent: :destroy, inverse_of: :scoring_rule
  has_many :users, through: :scoring_rule_participations
  has_many :scoring_rule_course_holes, dependent: :destroy
  has_many :course_holes, -> { order(:hole_number) }, through: :scoring_rule_course_holes

  accepts_nested_attributes_for :course_holes

  validates :dues_amount, presence: true
  validates :dues_amount, numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :selected_class_name

  def form_class
    becomes(ScoringRule)
  end

  def name
    raise 'A Base Class Has No Name'
  end

  def allows_custom_name?
    false
  end

  def name_with_cost
    "#{name} ($#{dues_amount.to_i})"
  end

  def description
    raise 'N/A'
  end

  def tournament
    tournament_day.tournament
  end

  def legacy_game_type_id
    0
  end

  def scoring_computer
    raise 'A Base Class Has No Scoring Computer'
  end

  def handicap_computer
    HandicapComputer::BaseHandicapComputer.new(self)
  end

  def scorecard_api(scorecard:)
    return nil if scorecard.blank?

    handicap_allowance = handicap_computer.handicap_allowance(user: scorecard.golf_outing.user)
    Scorecards::Api::ScorecardAPIBase.new(scorecard.tournament_day, scorecard, handicap_allowance).scorecard_representation
  end

  def individual_tournament_day_results
    tournament_day_results.where(aggregated_result: false)
  end

  def aggregate_tournament_day_results
    tournament_day_results.where(aggregated_result: true)
  end

  def has_aggregated_results?
    aggregate_tournament_day_results.count.positive?
  end

  def ranked_results
    # base class does nothing
  end

  def team_type
    ScoringRuleTeamType::NONE
  end

  def teams_are_player_vs_player?
    false # some team rules aggregate scores and some are individual vs individual on other team
  end

  def can_be_primary?
    true
  end

  def results_description_column_name
    nil
  end

  def users_per_daily_team
    1
  end

  def override_scorecard_name(scorecard:)
    nil
  end

  def optional_by_default
    false
  end

  def payout_type
    ScoringRulePayoutType::PREDETERMINED
  end

  def payout_assignment_type
    ScoringRulePayoutAssignmentType::CALCULATED
  end

  # Some scoring rules, like former contests, apply to the whole field, while some, like former game types, apply by flight.
  def flight_based_payouts?
    true
  end

  def can_be_played?
    return true if tournament_day.data_was_imported == true
    return false if tournament_day.tournament_groups.count.zero?
    return false if tournament_day.flights.count.zero?
    return false if tournament_day.scorecard_base_scoring_rule.blank?

    true
  end

  def can_be_finalized?
    return false if flight_payouts.count.zero?
    return false unless tournament_day.has_scores?
    return false if users.count.zero? && payout_assignment_type != ScoringRulePayoutAssignmentType::MANUAL

    true
  end

  def finalization_blockers
    blockers = []

    blockers << "#{name}: There are no payouts associated with flights." if flight_payouts.count.zero?
    blockers << "#{name}: This tournament day has no scores." unless tournament_day.has_scores?
    blockers << "#{name}: There are no users for this game type." if users.count.zero? && payout_assignment_type != ScoringRulePayoutAssignmentType::MANUAL

    blockers
  end

  def calculate_each_entry?
    true
  end

  def show_other_scorecards?
    false
  end

  def show_course_holes?
    true
  end

  def includes_extra_scoring_column?
    false
  end

  def associated_text_for_score(score)
    nil
  end

  def leaderboard_partial_name
    'standard_leaderboard'
  end

  def score
    scoring_computer.generate_tournament_day_results
  end

  def rank
    scoring_computer.rank_results
  end

  def assign_payouts
    scoring_computer.assign_payouts
  end

  def finalize; end

  def result_for_user(user:)
    tournament_day_results.find_by(user: user)
  end

  def points_for_user(user:)
    return 0 unless users.include? user

    points = 0

    payout_results.each do |p|
      points += p.points if p.user == user && p.points
    end

    points
  end

  def payouts_for_user(user:)
    return 0 unless users.include? user

    payouts = 0

    payout_results.each do |p|
      payouts += p.payout_amount if p.user == user && p.payout_amount
    end

    payouts
  end

  def flight_payouts
    @flight_payouts ||= tournament_day.flights.map(&:payouts).flatten
  end

  def users_eligible_for_payouts
    @users_eligible_for_payouts ||= users.where(scoring_rule_participations: { disqualified: false }).uniq
  end

  def cost_breakdown_for_user(user:, include_credit_card_fees: true)
    cost_lines = [
      { name: "#{name} Fees", price: dues_amount.to_f, server_id: id.to_s }
    ]

    if include_credit_card_fees
      cost_lines << { name: 'Credit Card Fees', price: Stripe::StripeFees.fees_for_transaction_amount(dues_amount) }
    end

    cost_lines
  end

  def dues_for_user(user:, include_credit_card_fees: false)
    membership = user.league_memberships.find_by(league: tournament_day.tournament.league)

    if membership.blank?
      0
    else
      dues_amount = self.dues_amount

      credit_card_fees = 0
      credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(dues_amount) if include_credit_card_fees

      total = dues_amount + credit_card_fees

      total
    end
  end

  def legacy_contest_winners
    winners = []

    payout_results.each do |r|
      winners << { contest_name: name, name: r.user.complete_name, result_value: r.detail, amount: r.amount, points: r.points, user: r.user }
    end

    winners
  end
end

class ScoringRuleOption
  attr_accessor :name
  attr_accessor :class_name

  def self.option(name:, class_name:)
    o = ScoringRuleOption.new
    o.name = name
    o.class_name = class_name

    o
  end

  def self.scoring_rule_options(show_team_rules: false)
    individual = [
      ScoringRuleOption.option(name: 'Individual Stroke Play', class_name: 'StrokePlayScoringRule'),
      ScoringRuleOption.option(name: 'Individual Modified Stableford', class_name: 'StablefordScoringRule'),
      ScoringRuleOption.option(name: 'Match Play', class_name: 'MatchPlayScoringRule'),
      ScoringRuleOption.option(name: 'Two Man Best Ball', class_name: 'TwoManBestBallScoringRule'),
      ScoringRuleOption.option(name: 'Two Man Scramble', class_name: 'TwoManScrambleScoringRule'),
      ScoringRuleOption.option(name: 'Four Man Scramble', class_name: 'FourManScrambleScoringRule'),
      ScoringRuleOption.option(name: 'Gross Skins', class_name: 'GrossSkinsScoringRule'),
      ScoringRuleOption.option(name: 'Net Skins', class_name: 'NetSkinsScoringRule'),
      ScoringRuleOption.option(name: 'Net Skins + Gross Birdies', class_name: 'TotalSkinsScoringRule'),
      ScoringRuleOption.option(name: 'Net Low', class_name: 'NetLowScoringRule'),
      ScoringRuleOption.option(name: 'Gross Low', class_name: 'GrossLowScoringRule'),
      ScoringRuleOption.option(name: 'Custom', class_name: 'ManualScoringRule'),
    ]

    team = [
      ScoringRuleOption.option(name: 'Team Stroke Play (Sum of Individual Scores)', class_name: 'TeamStrokePlayIndividualSumScoringRule'),
      ScoringRuleOption.option(name: 'Team Stroke Play (vs. Opposing Team Member)', class_name: 'TeamStrokePlayVsScoringRule'),
      ScoringRuleOption.option(name: 'Team Match Play (vs. Opposing Team Member)', class_name: 'TeamMatchPlayVsScoringRule'),
      ScoringRuleOption.option(name: 'Team Match Play (Best Ball)', class_name: 'TeamMatchPlayBestBallScoringRule'),
      ScoringRuleOption.option(name: 'Team Match Play (vs. Opposing Team Member) Points Per Hole', class_name: 'TeamMatchPlayVsPointsPerHoleScoringRule'),
      ScoringRuleOption.option(name: 'Team Best Ball', class_name: 'TeamBestBallScoringRule'),
    ]

    if show_team_rules
      [['Individual Game Types', individual], ['Team Game Types', team]]
    else
      [['Individual Game Types', individual]]
    end
  end
end
