module ScoringComputer
  class TeamStrokePlayVsScoringComputer < StrokePlayScoringComputer
    def assign_payouts
      Rails.logger.debug { "assign_payouts #{self.class}" }

      @scoring_rule.payout_results.destroy_all

      payout_count = @scoring_rule.payouts.count
      Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count.zero?

      eligible_users = @scoring_rule.users_eligible_for_payouts

      winners = []
      losers = []
      ties = []

      eligible_users.each do |user|
        next if winners.include?(user) || losers.include?(user) || ties.include?(user) # this means we already handled this matchup

        opponent = @scoring_rule.opponent_for_user(user)
        next if opponent.blank?

        if !eligible_users.include?(opponent) # opponent was disqualified, user wins
          winners << user
        else
          user_result = @scoring_rule.tournament_day_results.find_by(user: user)
          opponent_result = @scoring_rule.tournament_day_results.find_by(user: opponent)
          next if user_result.blank? && opponent_result.blank?

          if user_result.present? && opponent_result.blank?
            user_wins(user, opponent, winners, losers)

            next
          elsif opponent_result.present? && user_result.blank?
            opponent_wins(user, opponent, winners, losers)

            next
          end

          if opponent_result.blank? || user_result.par_related_net_score < opponent_result.par_related_net_score
            user_wins(user, opponent, winners, losers)
          elsif user_result.par_related_net_score > opponent_result.par_related_net_score
            opponent_wins(user, opponent, winners, losers)
          else
            tie(user, opponent, ties)
          end
        end
      end

      primary_payout = @scoring_rule.payouts.first
      return unless primary_payout.apply_as_duplicates?

      # winners
      winners.each do |u|
        PayoutResult.create(scoring_rule: @scoring_rule, user: u, points: primary_payout.points)
      end

      # ties
      ties.each do |u|
        PayoutResult.create(scoring_rule: @scoring_rule, user: u, points: primary_payout.points / 2)
      end
    end

    def user_wins(user, opponent, winners, losers)
      winners << user
      losers << opponent
    end

    def opponent_wins(user, opponent, winners, losers)
      winners << opponent
      losers << user
    end

    def tie(user, opponent, ties)
      ties << user
      ties << opponent
    end
  end
end
