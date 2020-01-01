module ScoringComputer
  class TeamMatchPlayVsPointsPerHoleScoringComputer < MatchPlayScoringComputer
    def assign_payouts
      Rails.logger.debug { "assign_payouts #{self.class}" }

      @scoring_rule.payout_results.destroy_all

      eligible_users = @scoring_rule.users_eligible_for_payouts
      eligible_users.each do |user|
        user_match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(user)
        next unless user_match_play_scorecard.match_has_ended?

        points_won = user_match_play_scorecard.points_per_hole_award

        PayoutResult.create(scoring_rule: @scoring_rule, user: user, points: points_won)
      end
    end
  end
end
