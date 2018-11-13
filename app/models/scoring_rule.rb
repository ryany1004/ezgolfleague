class ScoringRule < ApplicationRecord
	include ::ScoringRuleScoring

	belongs_to :tournament_day, touch: true, inverse_of: :scoring_rules
	has_many :payout_results, inverse_of: :scoring_rule, dependent: :destroy

	attr_accessor :selected_class_name

	def name
		"BASE_CLASS"
	end

	def tournament
		tournament_day.tournament
	end

	def ranked_results
		#base class does nothing
	end

	def users_per_team
		1
	end

	def can_be_played?
		false
	end

	def can_be_finalized?
		if self.flight_payouts.count == 0 || self.users.count == 0 || !self.tournament_day.has_scores?
			false
		else
			true
		end
	end

	def points_for_user(user:)
	  return nil if !self.users.include? user

	  points = 0

	  self.payout_results.each do |p|
	    points = points + p.points if p.user == user && p.points
	  end

	  points
	end

	def payouts_for_user(user:)
	  return nil if !self.users.include? user

	  payouts = 0

	  self.payout_results.each do |p|
	    payouts = payouts + p.payout_amount if p.user == user && p.payout_amount
	  end

	  payouts
	end

	def flight_payouts
		tournament_day.flights.map(&:payouts).flatten
	end

	def users
		self.tournament.players
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
			ScoringRuleOption.option(name: "Individual Stroke Play", class_name: "StrokePlayScoringRule")
		]
	end
end
