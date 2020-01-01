module BestBallScorecardSupport
  def related_scorecards_for_user(user, only_human_scorecards = false)
    if instance_of?(BestBallScoringRule) || instance_of?(TwoManBestBallScoringRule)
      daily_team_related_scorecards_for_user(user, only_human_scorecards)
    elsif instance_of?(TeamBestBallScoringRule)
      league_team_four_best_ball_related_scorecards_for_user(user, only_human_scorecards)
    else
      raise 'BestBallScorecardSupport missing a related_scorecards_for_user identifier - this is an error'
    end
  end

  def daily_team_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    team = tournament_day.daily_team_for_player(user)
    unless team.blank?
      team.users.each do |u|
        if u != user
          user_scorecard = tournament_day.primary_scorecard_for_user(u)
          other_scorecards << user_scorecard if user_scorecard.present?
        end
      end
    end

    if !only_human_scorecards
      gross_best_ball_card = best_ball_scorecard_for_user_in_team(user, team, false)
      net_best_ball_card = best_ball_scorecard_for_user_in_team(user, team, true)

      other_scorecards << net_best_ball_card if net_best_ball_card.present?
      other_scorecards << gross_best_ball_card if gross_best_ball_card.present?
    end

    other_scorecards
  end

  def league_team_four_best_ball_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    matchup = tournament_day.league_season_team_matchup_for_player(user)

    # add the other teammates for the user
    if matchup.present?
      matchup.team_users_for_user(user).each do |team_user|
        next if user == team_user

        user_scorecard = tournament_day.primary_scorecard_for_user(team_user)
        other_scorecards << user_scorecard if user_scorecard.present?
      end
    end

    # add user's team Best Ball
    unless only_human_scorecards
      league_season_team = tournament_day.league_season_team_for_player(user)

      if league_season_team.present?
        team_best_ball_scorecard = best_ball_scorecard_for_team(league_season_team)

        other_scorecards << team_best_ball_scorecard
      end
    end

    # add the opponent and teammates
    opponent = opponent_for_user(user)
    if opponent.present?
      matchup.team_users_for_user(opponent).each do |team_user|
        user_scorecard = tournament_day.primary_scorecard_for_user(team_user)
        other_scorecards << user_scorecard if user_scorecard.present?
      end

      # add opponent team Best Ball
      unless only_human_scorecards
        league_season_team = tournament_day.league_season_team_for_player(opponent)

        if league_season_team.present?
          team_best_ball_scorecard = best_ball_scorecard_for_team(league_season_team)

          other_scorecards << team_best_ball_scorecard
        end
      end
    end

    other_scorecards
  end
end
