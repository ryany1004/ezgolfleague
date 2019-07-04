module ScoringComputer
  class MatchPlayScoringComputer < StrokePlayScoringComputer
    def outcome_lists_include_user(outcome_lists, user)
      outcome_lists.each do |list|
        result = list.map(&:values).flatten.include? user

        return true if result
      end

      false
    end

    def assign_payouts
      Rails.logger.debug { "assign_payouts #{self.class}" }

      @scoring_rule.payout_results.destroy_all

      payout_count = @scoring_rule.payouts.count
      Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count.zero?

      eligible_users = @scoring_rule.users_eligible_for_payouts

      winners = []
      ties = []
      losers = []

      eligible_users.each do |user|
        next if outcome_lists_include_user([winners, losers, ties], user) # this means we already handled this matchup

        opponent = @scoring_rule.opponent_for_user(user)
        next if opponent.blank?

        if !eligible_users.include?(opponent) # opponent was disqualified, user wins
          winners << { user: user, detail: 'W' }
        else
          user_match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(user)
          if user_match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::WON # in this case, we are good
            winners << { user: user, detail: user_match_play_scorecard.extra_scoring_column_data }
          elsif user_match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::TIED
            ties << { user: user, detail: user_match_play_scorecard.extra_scoring_column_data, tie_identifier: "#{user.id}-#{opponent.id}" }

            opponent_match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(opponent)
            ties << { user: opponent, detail: opponent_match_play_scorecard.extra_scoring_column_data, tie_identifier: "#{user.id}-#{opponent.id}" }
          elsif user_match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::LOST
            losers << { user: user, detail: user_match_play_scorecard.extra_scoring_column_data }
          end
        end
      end

      # winners
      unclaimed_payouts = []
      @scoring_rule.payouts.each_with_index do |payout, i|
        if payout.payout_results.count.zero?
          if winners.count > i
            winner = winners[i]

            PayoutResult.create(payout: payout, user: winner[:user], scoring_rule: @scoring_rule, amount: payout.amount, points: payout.points, detail: winner[:detail])
          else
            unclaimed_payouts << payout
          end
        end
      end

      # ties
      grouped_ties = ties.group_by { |i| i[:tie_identifier] }
      unclaimed_payouts.each_with_index do |payout, i|
        next unless i < grouped_ties.keys.count

        tie_group_identifier = grouped_ties.keys[i]
        grouped_ties[tie_group_identifier].each do |winner|
          PayoutResult.create(payout: payout, user: winner[:user], scoring_rule: @scoring_rule, amount: payout.amount / 2, points: payout.points / 2, detail: winner[:detail])
        end
      end
    end
  end
end
