module ScoringComputer
  class TeamMatchPlayScramblePointsPerHoleScoringComputer < TeamMatchPlayVsPointsPerHoleScoringComputer
    def assign_payouts
      Rails.logger.debug { "assign_payouts #{self.class}" }

      @scoring_rule.payout_results.destroy_all

      users_scored = []

      eligible_users = @scoring_rule.users_eligible_for_payouts
      eligible_users.each do |user|
        next if users_scored.include? user

        user_match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(user)
        next unless user_match_play_scorecard.match_has_ended?

        points_won = user_match_play_scorecard.points_per_hole_award

        team = tournament_day.league_season_team_for_player(user)
        users_scored += team.users

        PayoutResult.create(scoring_rule: @scoring_rule, league_season_team: team, points: points_won)
      end
    end

    def after_updating_scores_for_scorecard(scorecard:)
      Scorecard.transaction do
        @scoring_rule.other_group_members(user: scorecard.golf_outing.user).each do |player|
          other_scorecard = tournament_day.primary_scorecard_for_user(player)

          Rails.logger.debug { "Copying Score Data From #{scorecard.golf_outing.user.complete_name} to #{player.complete_name}" }

          scorecard.scores.each do |score|
            other_score = other_scorecard.scores.find_by(course_hole: score.course_hole)
            other_score.strokes = score.strokes
            other_score.save
          end

          # make sure the results get updated also
          @scoring_rule.individual_tournament_day_results.where(user: player).destroy_all
        end
      end
    end
  end
end
