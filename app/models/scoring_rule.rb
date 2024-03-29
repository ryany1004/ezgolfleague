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
  has_many :payout_results, -> { order(:flight_id, amount: :desc, points: :desc, sorting_hint: :asc) }, inverse_of: :scoring_rule, dependent: :destroy
  has_many :tournament_day_results, -> { order(:flight_id, :sort_rank) }, inverse_of: :scoring_rule, dependent: :destroy
  has_many :scoring_rule_participations, dependent: :destroy, inverse_of: :scoring_rule
  has_many :users, through: :scoring_rule_participations
  has_many :scoring_rule_course_holes, dependent: :destroy
  has_many :course_holes, -> { order(:hole_number) }, through: :scoring_rule_course_holes

  accepts_nested_attributes_for :course_holes

  validates :dues_amount, presence: true
  validates :dues_amount, numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :selected_class_name
  
  def name
    raise 'A Base Class Has No Name'
  end

  def name_with_tournament
    "#{name} (#{tournament_day.tournament.name})"
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
    HandicapComputers::BaseHandicapComputer.new(self)
  end

  def scorecards
    users.map { |u| tournament_day.primary_scorecard_for_user(u) }.compact
  end

  def scorecard_api(scorecard:)
    return nil if scorecard.blank?

    handicap_allowance = handicap_computer.handicap_allowance(user: scorecard.golf_outing.user)
    Scorecards::Api::ScorecardApiBase.new(scorecard.tournament_day, scorecard, handicap_allowance).scorecard_representation
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
    return true if tournament_day.data_was_imported
    return false if tournament_day.tournament_groups.count.zero?
    return false if tournament_day.flights.count.zero?
    return false if tournament_day.scorecard_base_scoring_rule.blank?
    return false if scoring_rule_course_holes.count.zero?

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

  def hole_configuration
    if course_holes.count == 18
      { name: 'All 18', value: 'allHoles' }
    elsif course_holes.count == 9
      if course_holes.first.hole_number == '1'
        { name: 'Front 9', value: 'frontNine' }
      else
        { name: 'Back 9', value: 'backNine' }
      end
    else
      { name: 'Custom', value: 'custom' }
    end
  end

  def flight_payouts
    @flight_payouts ||= tournament_day.flights.map(&:payouts).flatten
  end

  def users_eligible_for_payouts
    @users_eligible_for_payouts ||= users.where(scoring_rule_participations: { disqualified: false }).uniq
  end

  def user_disqualified?(user)
    participation = scoring_rule_participations.find_by(user: user)
    participation.present? ? participation.disqualified : false
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
      winners << { item_id: r.id,
                   contest_name: name,
                   name: r.user&.complete_name,
                   result_value: r.detail.presence || '',
                   amount: r.amount.presence || '',
                   points: r.points.to_i,
                   user: r.user }
    end

    winners
  end
end

class ScoringRuleOption
  attr_accessor :name, :class_name, :custom_name_allowed, :setup_component_name, :show_course_holes, :custom_configuration

  def self.option(name:, class_name:, custom_name_allowed:, setup_component_name:, show_course_holes:, custom_configuration:)
    o = ScoringRuleOption.new

    o.name = name
    o.class_name = class_name
    o.custom_name_allowed = custom_name_allowed
    o.setup_component_name = setup_component_name
    o.show_course_holes = show_course_holes
    o.custom_configuration = custom_configuration

    o
  end

  def self.scoring_rule_options(show_team_rules: false)
    individual_classes = [
      'StrokePlayScoringRule',
      'StablefordScoringRule',
      # 'MatchPlayScoringRule',
      # 'TwoManBestBallScoringRule',
      # 'TwoManScrambleScoringRule',
      # 'FourManScrambleScoringRule',
      # 'GrossSkinsScoringRule',
      'ThreeBestBallsOfFourScoringRule',
      # 'NetSkinsScoringRule',
      # 'TotalSkinsScoringRule',
      # 'NetLowScoringRule',
      # 'GrossLowScoringRule',
      # 'ManualScoringRule'
    ]

    individual = []
    individual_classes.each do |i|
      instance = i.constantize.new

      individual << ScoringRuleOption.option(name: instance.name,
                                             class_name: i,
                                             custom_name_allowed: instance.allows_custom_name?,
                                             setup_component_name: instance.setup_component_name,
                                             show_course_holes: instance.show_course_holes?,
                                             custom_configuration: instance.custom_configuration_params)
    end

    team_classes = [
      # 'TeamStrokePlayIndividualSumScoringRule',
      # 'TeamStrokePlayVsScoringRule',
      # 'TeamMatchPlayVsScoringRule',
      # 'TeamMatchPlayBestBallScoringRule',
      # 'TeamMatchPlayScramblePointsPerHoleScoringRule',
      # 'TeamMatchPlayVsPointsPerHoleScoringRule',
      # 'TeamBestBallScoringRule'
    ]

    team = []
    team_classes.each do |i|
      instance = i.constantize.new

      team << ScoringRuleOption.option(name: instance.name,
                                       class_name: i,
                                       custom_name_allowed: instance.allows_custom_name?,
                                       setup_component_name: instance.setup_component_name,
                                       show_course_holes: instance.show_course_holes?,
                                       custom_configuration: instance.custom_configuration_params)
    end

    if show_team_rules
      [['Individual Game Types', individual], ['Team Game Types', team]]
    else
      [[type: 'Individual Game Types', games: individual]]
    end
  end
end
