class TournamentDayResult < ApplicationRecord
	include Rails.application.routes.url_helpers

  belongs_to :scoring_rule, inverse_of: :tournament_day_results, touch: true
  belongs_to :user, inverse_of: :tournament_day_results
  belongs_to :primary_scorecard, class_name: "Scorecard", foreign_key: "user_primary_scorecard_id" #TEAM: does this need to be primary_scorecard(s) instead?
  belongs_to :flight, inverse_of: :tournament_day_results, touch: true

  validates :name, presence: true

  def tournament_day
    scoring_rule.tournament_day
  end

  #TODO: refactor, could store not compute
  def points
    return 0 if flight.blank?

    total_points = 0
    
    flight.payout_results.where(user: user).where("points > 0").each do |payout_result|
      total_points += payout_result.points
    end

    tournament_day.contests.each do |c|
      c.contest_results.where(winner: user).where("points > 0").each do |payout_result|
        total_points += payout_result.points
      end
    end

    total_points
  end

  def payouts
    return 0 if flight.blank?

    total_payouts = 0

    flight.payout_results.where(user: user).each do |payout_result|
      total_payouts += payout_result.amount
    end

    tournament_day.contests.each do |c|
      c.contest_results.where(winner: user).each do |payout_result|
        total_payouts += payout_result.payout_amount
      end
    end   

    total_payouts
  end

  def raw_scores
  	primary_scorecard.scores.map(&:strokes)
  end

  #TODO: this should be refactored, calc's handicaps each time
  def net_scores
  	handicaps = tournament_day.handicap_allowance(user: user)
    primary_scorecard.net_scores(handicap_allowance: handicaps)
  end

  def scorecard_url
  	play_scorecard_path(primary_scorecard)
  end

  def thru
  	primary_scorecard.last_hole_played
  end

  def to_s
    "#{self.user&.complete_name} - Net: #{self.net_score} Gross: #{self.gross_score}"
  end
end