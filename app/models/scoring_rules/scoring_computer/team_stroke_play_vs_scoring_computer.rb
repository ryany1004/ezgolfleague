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

          if opponent_result.blank? || user_result.par_related_net_score < opponent_result.par_related_net_score
            winners << user
            losers << opponent
          elsif user_result.par_related_net_score > opponent_result.par_related_net_score
            winners << opponent
            losers << user
          else
            ties << user
            ties << opponent
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
  end
end
