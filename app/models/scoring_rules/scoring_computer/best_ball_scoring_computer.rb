module ScoringComputer
  class BestBallScoringComputer < StrokePlayScoringComputer
    def generate_tournament_day_result(user:, scorecard: nil)
      team = tournament_day.daily_team_for_player(user)
      daily_team_scorecard = @scoring_rule.best_ball_scorecard_for_user_in_team(user, team, true)
      return nil if daily_team_scorecard.blank? || daily_team_scorecard.scores.blank?

      result = super(user: user, scorecard: daily_team_scorecard)

      # remove any other results with the same name to de-dupe the teams
      @scoring_rule.tournament_day_results.where(name: result.name).where.not(id: result.id).destroy_all if result.present?

      result
    end

    def assign_payouts
      @scoring_rule.payout_results.destroy_all

      payout_count = @scoring_rule.payouts.count
      Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count.zero?

      daily_team_winners = []

      ranked_flights = self.ranked_flights
      ranked_flights.each do |flight|
        flight.payouts.where(scoring_rule: @scoring_rule).each_with_index do |payout, i|
          next unless payout.payout_results.count.zero?

          result = payout_recipient(flight, i, daily_team_winners)
          next unless result.present?

          daily_team = tournament_day.daily_team_for_player(result.user)
          daily_team_winners << daily_team if daily_team.present?

          player = result.user

          Rails.logger.debug { "Assigning #{player.complete_name}. Result [#{result}] Payout [#{payout}] Scoring Rule [#{@scoring_rule.name} #{@scoring_rule.id}]" }

          PayoutResult.create(payout: payout, user: player, scoring_rule: @scoring_rule, flight: flight, amount: payout.amount, points: payout.points)
        end
      end

      split_team_payouts
    end

    def payout_recipient(flight, starting_index, daily_team_winners)
      eligible_users = @scoring_rule.users_eligible_for_payouts
      full_results = flight.tournament_day_results.where(scoring_rule: @scoring_rule)
      sliced_array = full_results[starting_index..-1]

      sliced_array.each do |result|
        daily_team = tournament_day.daily_team_for_player(result.user)
        is_eligible = eligible_users.include? result.user
        daily_team_has_already_won = daily_team_winners.include? daily_team

        next if !is_eligible || daily_team_has_already_won

        return result
      end
    end

    def split_team_payouts
      payout_results = @scoring_rule.reload.payout_results

      payout_results.each do |result|
        daily_team = tournament_day.daily_team_for_player(result.user)

        if daily_team.present?
          payout_amount = (result.amount / daily_team.users.count.to_f).floor

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
