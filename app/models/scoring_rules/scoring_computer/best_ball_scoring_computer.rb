module ScoringComputer
  class BestBallScoringComputer < StrokePlayScoringComputer
    def generate_tournament_day_result(user:, scorecard: nil)
      team = tournament_day.daily_team_for_player(user)
      daily_team_scorecard = @scoring_rule.best_ball_scorecard_for_user_in_team(user, team, true)
      return nil if daily_team_scorecard.blank? || daily_team_scorecard.scores.blank?

      super(user: user, scorecard: daily_team_scorecard)
    end

    def assign_payouts
      super

      payout_results = @scoring_rule.reload.payout_results

      payout_results.each do |result|
        daily_team = tournament_day.daily_team_for_player(result.user)

        if daily_team.present?
          payout_amount = result.amount / @scoring_rule.users_per_daily_team.to_f

          daily_team.users.each do |u|
            if u != result.user
              PayoutResult.create(payout: result.payout, user: u, scoring_rule: @scoring_rule, flight: result.flight, amount: payout_amount, points: result.points)
            else
              result.amount = payout_amount
              result.save
            end
          end
        else
          Rails.logger.debug { "Daily Team Blank For User ID #{result.user.id}" }
        end
      end
    end
  end
end
