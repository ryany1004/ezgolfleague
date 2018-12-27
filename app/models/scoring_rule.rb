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
	belongs_to :tournament_day, touch: true, inverse_of: :scoring_rules
	has_many :payouts, inverse_of: :scoring_rule, dependent: :destroy
	has_many :payout_results, -> { order(:flight_id, amount: :desc) }, inverse_of: :scoring_rule, dependent: :destroy
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

	def description
		raise "N/A"
	end

	def tournament
		tournament_day.tournament
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

	def ranked_results
		#base class does nothing
	end

	def team_type
		ScoringRuleTeamType::NONE
	end

	def users_per_daily_team
		1
	end

	def override_scorecard_name(scorecard:)
		nil
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
	  return false if self.tournament_day.scorecard_base_scoring_rule.count == 0

	  true
	end

	def can_be_finalized?
		if self.flight_payouts.count == 0 || self.users.count == 0 || !self.tournament_day.has_scores?
			false
		else
			true
		end
	end

	def show_other_scorecards?
		false
	end

	def leaderboard_partial_name
		nil
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
		tournament_day.flights.map(&:payouts).flatten
	end

	def users_eligible_for_payouts
		self.users
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

	def self.scoring_rule_options
		[
			ScoringRuleOption.option(name: 'Individual Stroke Play', class_name: 'StrokePlayScoringRule'),
			ScoringRuleOption.option(name: 'Individual Modified Stableford', class_name: 'StablefordScoringRule'),
			ScoringRuleOption.option(name: 'Two Man Best Ball', class_name: 'TwoManBestBallScoringRule'),
			ScoringRuleOption.option(name: 'Two Man Scramble', class_name: 'TwoManScrambleScoringRule'),
			ScoringRuleOption.option(name: 'Four Man Scramble', class_name: 'FourManScrambleScoringRule'),
			ScoringRuleOption.option(name: 'Four Man Scramble', class_name: 'FourManScrambleScoringRule'),
			ScoringRuleOption.option(name: 'Gross Skins', class_name: 'GrossSkinsScoringRule'),
			ScoringRuleOption.option(name: 'Net Skins', class_name: 'NetSkinsScoringRule'),
		]
	end
end
