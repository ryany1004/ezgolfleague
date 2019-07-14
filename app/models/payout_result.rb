class PayoutResult < ApplicationRecord
  acts_as_paranoid

  belongs_to :payout, inverse_of: :payout_results, optional: true, touch: true
  belongs_to :flight, inverse_of: :payout_results, optional: true, touch: true
  belongs_to :user, inverse_of: :payout_results, optional: true
  belongs_to :league_season_team, inverse_of: :payout_results, optional: true
  belongs_to :scoring_rule, inverse_of: :payout_results, touch: true
  belongs_to :scoring_rule_course_hole, optional: true

  delegate :net_score, to: :tournament_day_result, allow_nil: true
  delegate :par_related_net_score, to: :tournament_day_result, allow_nil: true

  validate :user_or_league_season_team_present

  def user_or_league_season_team_present
    errors.add(:user, 'Specify a user') if user.blank? && league_season_team.blank?
  end

  def name
    if user.present?
      user.complete_name
    elsif league_season_team.present?
      league_season_team.name
    else
      'N/A'
    end
  end

  def display_name
    if daily_team.present?
      daily_team.short_name
    elsif flight.present?
      flight.display_name
    else
      scoring_rule.name
    end
  end

  def course_handicap
    return nil if user.blank?

    golf_outing = scoring_rule.tournament_day.golf_outing_for_player(user)
    return nil if golf_outing.blank?

    golf_outing.course_handicap.to_i
  end

  def daily_team
    scoring_rule.tournament_day.daily_team_for_player(user)
  end

  def team_matchup_designator
    return nil unless scoring_rule.teams_are_player_vs_player?

    team = scoring_rule.tournament_day.league_season_team_for_player(user)
    matchup = scoring_rule.tournament_day.league_season_team_matchup_for_team(team)
    matchup.matchup_indicator_for_user(user) if matchup.present?
  end

  def tournament_day_result
    if league_season_team.present?
      scoring_rule.aggregate_tournament_day_results.find_by(league_season_team: league_season_team)
    else
      scoring_rule.individual_tournament_day_results.find_by(user: user)
    end
  end
end
