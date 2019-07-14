module ThreeBestBallsOfFourScorecardSupport
  def related_scorecards_for_user(user, only_human_scorecards = false)
    if instance_of?(ThreeBestBallsOfFourScoringRule)
      daily_team_related_scorecards_for_user(user, only_human_scorecards)
    else
      raise 'ThreeBestBallsOfFourScoringRule missing a related_scorecards_for_user identifier - this is an error'
    end
  end

  def daily_team_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    team = tournament_day.daily_team_for_player(user)
    if team.present?
      team.users.each do |u|
        if u != user
          user_scorecard = tournament_day.primary_scorecard_for_user(u)
          other_scorecards << user_scorecard if user_scorecard.present?
        end
      end
    end

    unless only_human_scorecards
      if team.present? && include_ghost_par_scores?(team.users)
        ghost_scorecard = ScoringRuleScorecards::GhostScorecard.new
        ghost_scorecard.scoring_rule = self
        ghost_scorecard.user = team.users.first
        ghost_scorecard.calculate_scores

        other_scorecards << ghost_scorecard
      end

      # gross_best_ball_card = best_ball_scorecard_for_user_in_team(user, team, false)
      net_best_ball_card = best_ball_scorecard_for_user_in_team(user, team, true)

      other_scorecards << net_best_ball_card if net_best_ball_card.present?
      # other_scorecards << gross_best_ball_card if gross_best_ball_card.present?
    end

    other_scorecards
  end
end
