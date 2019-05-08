module ScoringComputer
  class MatchPlayScoringComputer < StrokePlayScoringComputer
    def assign_payouts
      Rails.logger.debug { "assign_payouts #{self.class}" }

      @scoring_rule.payout_results.destroy_all

      payout_count = @scoring_rule.payouts.count
      Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count.zero?

      eligible_users = @scoring_rule.users_eligible_for_payouts

      users_with_holes_won = []

      eligible_users.each do |user|
        match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(user)

        users_with_holes_won << { user: user, holes_won: match_play_scorecard.holes_won, details: match_play_scorecard.extra_scoring_column_data }
      end

      # sort
      users_with_holes_won.sort! { |x, y| y[:holes_won] <=> x[:holes_won] }

      # assign payouts
      @scoring_rule.payouts.each_with_index do |payout, i|
        if payout.payout_results.count.zero?
          user = users_with_holes_won[i][:user]
          details = users_with_holes_won[i][:details]
          holes_won = users_with_holes_won[i][:holes_won]

          if user.present?
            amount = payout.amount
            points = payout.points

            others_tied = users_with_holes_won.select { |u| u[:holes_won] == holes_won }
            if others_tied.present? && others_tied.count > 1
              amount = (amount / others_tied.count).round if amount.positive?
              points = (points / others_tied.count).round if points.positive?

              others_tied.each do |tie|
                tie_user = tie[:user]
                tie_details = tie[:details]

                Rails.logger.debug { "TIE Assigning #{tie_user.complete_name}. HW: #{holes_won}. Payout [#{payout}] Scoring Rule [#{@scoring_rule.name} #{@scoring_rule.id}]" }

                PayoutResult.create(payout: payout, user: tie_user, scoring_rule: @scoring_rule, amount: amount, points: points, detail: tie_details)

                users_with_holes_won.each_with_index do |x, i|
                  users_with_holes_won.delete_at(i) if x[:user] == tie_user
                end
              end
            else
              Rails.logger.debug { "Assigning #{user.complete_name}. Payout [#{payout}] Scoring Rule [#{@scoring_rule.name} #{@scoring_rule.id}]" }

              PayoutResult.create(payout: payout, user: user, scoring_rule: @scoring_rule, amount: amount, points: points, detail: details)
            end
          end
        else
          Rails.logger.debug { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
        end
      end
    end
  end
end
