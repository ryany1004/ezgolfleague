module TournamentDays
  module RemoveFromTournamentDay
    def remove_player_from_group(tournament_group:, user:, remove_from_teams: false)
      Tournament.transaction do
        tournament_group.golf_outings.each do |outing|
          cache_key = self.cache_key(scorecard_cache_prefix(user: user))
          Rails.cache.write(cache_key, nil)

          if user.id == outing.scorecard&.designated_editor_id
            outing.scorecard.designated_editor_id = nil
            outing.scorecard.save
          end

          if outing.user == user
            outing.destroy
            break
          end
        end

        deflight_user(user: user)

        remove_from_daily_teams(tournament_group: tournament_group, user: user) if remove_from_teams

        remove_from_scoring_rules(user: user)

        refund_user(user: user) if self == tournament.first_day

        tournament_group.touch
      end
    end

    def deflight_user(user:)
      flight = flight_for_player(user)
      flight&.users&.delete(user)
    end

    def remove_from_scoring_rules(user:)
      scoring_rules.each do |rule|
        rule.users.destroy(user)
      end
    end

    def remove_from_daily_teams(tournament_group:, user:)
      Rails.logger.debug { 'Removing Player from Daily Teams' }

      tournament_group.daily_teams.each do |team|
        team.users.destroy(user) if team.users.include? user
      end
    end

    def refund_user(user:)
      previous_payments = Payment.where(user: user).where(scoring_rule: scorecard_base_scoring_rule).where('payment_amount < 0')
      previous_unrefunded_payments = previous_payments.select{ |item| item.credits.count.zero? }
      total_unrefunded_payment_amount = previous_unrefunded_payments.map(&:payment_amount).sum

      Rails.logger.debug { "Unrefunded Amount: #{total_unrefunded_payment_amount} From # of Transactions: #{previous_unrefunded_payments.count}" }

      refund = Payment.create(scoring_rule: scorecard_base_scoring_rule, payment_amount: total_unrefunded_payment_amount * -1.0, user: user, payment_source: 'Tournament Dues Credit')

      previous_unrefunded_payments.each do |p|
        p.credits << refund
        p.save
      end
    end
  end
end
