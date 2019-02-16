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
	has_many :payments, inverse_of: :scoring_rule
	has_many :payouts, inverse_of: :scoring_rule, dependent: :destroy
	has_many :payout_results, -> { order(:flight_id, amount: :desc, points: :desc) }, inverse_of: :scoring_rule, dependent: :destroy
	has_many :tournament_day_results, -> { order(:flight_id, :sort_rank) }, inverse_of: :scoring_rule, dependent: :destroy
	has_many :scoring_rule_participations, dependent: :destroy, inverse_of: :scoring_rule
	has_many :users, through: :scoring_rule_participations
	has_many :scoring_rule_course_holes
	has_many :course_holes, -> { order(:hole_number) }, through: :scoring_rule_course_holes

	accepts_nested_attributes_for :course_holes

	attr_accessor :selected_class_name

	def form_class
		becomes(ScoringRule)
	end

	def name
		raise "A Base Class Has No Name"
	end

  def name_with_cost
    "#{self.name} ($#{self.dues_amount.to_i})"
  end

	def description
		raise "N/A"
	end

	def tournament
		tournament_day.tournament
	end

	def legacy_game_type_id
		0
	end

	def scoring_computer
		raise "A Base Class Has No Scoring Computer"
	end

	def handicap_computer
		HandicapComputer::BaseHandicapComputer.new(self)
	end

	def scorecard_api
		raise "A Base Class Has No Scorecard API"
	end

	def individual_tournament_day_results
		self.tournament_day_results.where(aggregated_result: false)
	end

	def aggregate_tournament_day_results
		self.tournament_day_results.where(aggregated_result: true)
	end

	def ranked_results
		#base class does nothing
	end

	def team_type
		ScoringRuleTeamType::NONE
	end

	def users_per_daily_team
		1
	end

	def users_per_league_team
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

	#Some scoring rules, like former contests, apply to the whole field, while some, like former game types, apply by flight.
	def flight_based_payouts?
		true
	end

	def can_be_played?
	  return true if self.tournament_day.data_was_imported == true
	  return false if self.tournament_day.tournament_groups.count == 0
	  return false if self.tournament_day.flights.count == 0
	  return false if self.tournament_day.scorecard_base_scoring_rule.blank?

	  true
	end

	def can_be_finalized?
		return false if self.flight_payouts.count == 0
		return false if !self.tournament_day.has_scores?
		return false if self.users.count == 0 && self.payout_assignment_type != ScoringRulePayoutAssignmentType::MANUAL

		true
	end

	def finalization_blockers
		blockers = []

		blockers << "#{self.name}: There are no payouts associated with flights." if self.flight_payouts.count == 0
		blockers << "#{self.name}: This tournament day has no scores." if !self.tournament_day.has_scores?
		blockers << "#{self.name}: There are no users for this game type." if self.users.count == 0 && self.payout_assignment_type != ScoringRulePayoutAssignmentType::MANUAL

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
    return false
  end

  def associated_text_for_score(score)
    return nil
  end

	def leaderboard_partial_name
		'standard_leaderboard'
	end

	def score
    self.scoring_computer.generate_tournament_day_results
	end

	def rank
		self.scoring_computer.rank_results
	end

	def assign_payouts
		self.scoring_computer.assign_payouts
	end

	def result_for_user(user:)
		self.tournament_day_results.where(user: user).first
	end

	def points_for_user(user:)
	  return 0 unless self.users.include? user

	  points = 0

	  self.payout_results.each do |p|
	    points += p.points if p.user == user && p.points
	  end

	  points
	end

	def payouts_for_user(user:)
	  return 0 unless self.users.include? user

	  payouts = 0

	  self.payout_results.each do |p|
	    payouts += p.payout_amount if p.user == user && p.payout_amount
	  end

	  payouts
	end

	def flight_payouts
		@flight_payouts ||= tournament_day.flights.map(&:payouts).flatten
	end

	def users_eligible_for_payouts
		@users_eligible_for_payouts ||= self.users.where(scoring_rule_participations: { disqualified: false }).uniq
	end

  def cost_breakdown_for_user(user:, include_credit_card_fees: true)
    cost_lines = [
      { name: "#{self.name} Fees", price: self.dues_amount.to_f, server_id: self.id.to_s }
    ]

    if include_credit_card_fees == true
      cost_lines << {name: "Credit Card Fees", price: Stripe::StripeFees.fees_for_transaction_amount(self.dues_amount)}
    end

    cost_lines
  end

  def dues_for_user(user:, include_credit_card_fees: false)
    membership = user.league_memberships.where('league_id = ?', self.tournament_day.tournament.league.id).first

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

  	self.payout_results.each do |r|
  		winners << { contest_name: self.name, name: r.user.complete_name, result_value: r.detail, amount: r.amount, points: r.points, user: r.user }
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

		team  = [
			ScoringRuleOption.option(name: 'Team Stroke Play (Sum of Individual Scores)', class_name: 'TeamStrokePlayIndividualSumScoringRule'),
		]

		if show_team_rules
			individual + team
		else
			individual
		end
	end
end
