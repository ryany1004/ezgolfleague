class TournamentDayResult < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :scoring_rule, inverse_of: :tournament_day_results, touch: true
  belongs_to :user, inverse_of: :tournament_day_results, optional: true
  belongs_to :league_season_team, inverse_of: :tournament_day_results, optional: true
  belongs_to :primary_scorecard, class_name: 'Scorecard', foreign_key: 'user_primary_scorecard_id'
  belongs_to :flight, inverse_of: :tournament_day_results, optional: true, touch: true

  validates :name, presence: true

  def tournament_day
    scoring_rule.tournament_day
  end

  def name
    if league_season_team.present?
      league_season_team.name
    elsif read_attribute(:name).present?
      read_attribute(:name)
    elsif user.present?
      user.complete_name
    else
      'N/A'
    end
  end

  def payout_results_relation
    relation = scoring_rule.payout_results

    if user.present?
      relation.where(user: user)
    else
      relation.where(league_season_team: league_season_team)
    end
  end

  def combinable?(other_result)
    name == other_result.name
  end

  # TODO: refactor, could store not compute
  def points
    return 0 if user.present? && flight.blank?

    total_points = 0

    self.payout_results_relation.where('points > 0').each do |payout_result|
      total_points += payout_result.points
    end

    total_points
  end

  def payouts
    return 0 if flight.blank?

    total_payouts = 0

    payout_results_relation.where('amount > 0').each do |payout_result|
      total_payouts += payout_result.amount
    end

    total_payouts
  end

  def raw_scores
  	primary_scorecard.scores.map(&:strokes)
  end

  def net_scores
    primary_scorecard.scores.map(&:net_strokes)
  end

  def scorecard_url
  	play_scorecard_path(primary_scorecard)
  end

  def thru
  	primary_scorecard.last_hole_played
  end

  def matchup_position
    primary_scorecard.matchup_position_indicator
  end

  def to_s
    "#{name} - Net: #{net_score} Gross: #{gross_score}"
  end
end
