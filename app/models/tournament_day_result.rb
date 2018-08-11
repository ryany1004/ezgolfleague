class TournamentDayResult < ApplicationRecord
	include Rails.application.routes.url_helpers

  belongs_to :tournament_day, inverse_of: :tournament_day_results, touch: true
  belongs_to :user, inverse_of: :tournament_day_results
  belongs_to :primary_scorecard, :class_name => "Scorecard", :foreign_key => "user_primary_scorecard_id"
  belongs_to :flight, inverse_of: :tournament_day_results

  #TODO: refactor, could store not compute
  def points
    return 0 if flight.blank?

    total_points = 0
    flight.payout_results.where(user: user).each do |payout_result|
      total_points = payout_result.points
    end

    total_points
  end

  def payouts
    return 0 if flight.blank?

    total_payouts = 0
    flight.payout_results.where(user: user).each do |payout_result|
      total_payouts = payout_result.amount
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

  def ranking
    rank
  end

  #JSON

  def as_json(options={})
    super(
      :only => [:id, :name, :net_score, :back_nine_net_score, :gross_score, :par_related_net_score, :par_related_gross_score],
      :methods => [:thru, :points, :ranking]
    )
  end

end