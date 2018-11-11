class TournamentDayResult < ApplicationRecord
	include Rails.application.routes.url_helpers

  belongs_to :tournament_day, inverse_of: :tournament_day_results, touch: true
  belongs_to :user, inverse_of: :tournament_day_results
  belongs_to :primary_scorecard, :class_name => "Scorecard", :foreign_key => "user_primary_scorecard_id"
  #TEAM: does this need to be primary_scorecard(s) instead?
  #TEAM: do we also tie a TDR to the ScoringRule that generated it so we can display results by scoring rule

  belongs_to :flight, inverse_of: :tournament_day_results, touch: true

  validates :name, presence: true

  #TODO: refactor, could store not compute
  def points
    return 0 if flight.blank?

    total_points = 0
    
    flight.payout_results.where(user: user).each do |payout_result|
      total_points += payout_result.points
    end

    tournament_day.contests.each do |c|
      c.contest_results.where(winner: user).each do |payout_result|
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
  	handicaps = tournament_day.game_type.handicap_allowance(user)
  	tournament_day.game_type.net_scores_for_scorecard(handicaps, primary_scorecard)
  end

  def scorecard_url
  	play_scorecard_path(primary_scorecard)
  end

  def thru
  	primary_scorecard.last_hole_played
  end
end