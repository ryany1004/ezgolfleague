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

  def name
    if user.present?
      user.complete_name
    elsif league_season_team.present?
      league_season_team.name
    else
      "N/A"
    end
  end

  def display_name
  	if self.flight.present?
  		self.flight.display_name
  	else
  		self.scoring_rule.name
  	end
  end

  def team_matchup_designator
  	return nil if !self.scoring_rule.teams_are_player_vs_player?

  	team = self.scoring_rule.tournament_day.league_season_team_for_player(self.user)

  	if team.present?
  		team.matchup_indicator_for_user(self.user)
  	else
  		nil
  	end
  end

  def tournament_day_result
    if self.league_season_team.present?
      self.scoring_rule.aggregate_tournament_day_results.where(league_season_team: league_season_team).first
    else
      self.scoring_rule.individual_tournament_day_results.where(user: user).first
    end
  end
end
