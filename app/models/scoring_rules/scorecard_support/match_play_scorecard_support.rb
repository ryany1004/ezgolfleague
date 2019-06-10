module MatchPlayScorecardSupport
  def related_scorecards_for_user(user, only_human_scorecards = false)
    if instance_of?(MatchPlayScoringRule)
      daily_team_related_scorecards_for_user(user, only_human_scorecards)
    elsif instance_of?(TeamMatchPlayVsScoringRule) || instance_of?(TeamMatchPlayVsPointsPerHoleScoringRule)
      league_team_related_scorecards_for_user(user, only_human_scorecards)
    elsif instance_of?(TeamMatchPlayBestBallScoringRule)
      league_team_four_best_ball_related_scorecards_for_user(user, only_human_scorecards)
    elsif instance_of?(TeamMatchPlayScramblePointsPerHoleScoringRule)
      league_team_scramble_related_scorecards_for_user(user, only_human_scorecards)
    else
      raise 'MatchPlayScorecardSupport missing a related_scorecards_for_user identifier - this is an error'
    end
  end

  def daily_team_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    team = tournament_day.daily_team_for_player(user)
    if team.present?
      unless only_human_scorecards
        user_match_play_card = match_play_scorecard_for_user(user)
        other_scorecards << user_match_play_card
      end

      team.users.each do |u|
        next if u == user

        other_scorecards << tournament_day.primary_scorecard_for_user(u)

        unless only_human_scorecards
          other_user_match_play_card = match_play_scorecard_for_user(u)
          other_scorecards << other_user_match_play_card
        end
      end
    end

    other_scorecards
  end

  def league_team_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    unless only_human_scorecards
      user_match_play_card = match_play_scorecard_for_user(user)
      other_scorecards << user_match_play_card
    end

    opponent = opponent_for_user(user)
    if opponent.present?
      other_scorecards << tournament_day.primary_scorecard_for_user(opponent)

      unless only_human_scorecards
        opponent_match_play_card = match_play_scorecard_for_user(opponent)
        other_scorecards << opponent_match_play_card
      end
    end

    # add the other people from the group
    group = tournament_day.tournament_group_for_player(user)
    group&.golf_outings&.each do |outing|
      card = tournament_day.primary_scorecard_for_user(outing.user)

      next if card.user == user || other_scorecards.include?(card)

      other_scorecards << card
    end

    other_scorecards
  end

  def league_team_scramble_related_scorecards_for_user(user, only_human_scorecards = false)
    other_scorecards = []

    unless only_human_scorecards
      user_match_play_card = match_play_scorecard_for_user(user)
      other_scorecards << user_match_play_card
    end

    opponent = opponent_for_user(user)
    if opponent.present?
      other_scorecards << tournament_day.primary_scorecard_for_user(opponent)

      unless only_human_scorecards
        opponent_match_play_card = match_play_scorecard_for_user(opponent)
        other_scorecards << opponent_match_play_card
      end
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
