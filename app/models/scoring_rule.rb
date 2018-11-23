class ScoringRule < ApplicationRecord
	belongs_to :tournament_day, touch: true, inverse_of: :scoring_rules
	has_many :payouts, inverse_of: :scoring_rule, dependent: :destroy
	has_many :payout_results, inverse_of: :scoring_rule, dependent: :destroy
	has_many :tournament_day_results, -> { order(:flight_id, :sort_rank) }, inverse_of: :scoring_rule, dependent: :destroy

	attr_accessor :selected_class_name

	def form_class
		becomes(ScoringRule)
	end

	def name
		raise "Base Class Has No Name"
	end

	def tournament
		tournament_day.tournament
	end

	def scoring_computer
		raise "Base Class Has No Scoring Computer"
	end

	def ranked_results
		#base class does nothing
	end

	def users_per_team
		1
	end

	def can_be_played?
	  return true if self.tournament_day.data_was_imported == true

	  return false if self.tournament_day.tournament_groups.count == 0
	  return false if self.tournament_day.flights.count == 0
	  return false if self.tournament_day.course_holes.count == 0

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
		self.tournament.players_for_day(self.tournament_day)
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
