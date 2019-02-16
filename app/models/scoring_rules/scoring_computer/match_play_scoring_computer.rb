module ScoringComputer
	class MatchPlayScoringComputer < StrokePlayScoringComputer
		def assign_payouts
			Rails.logger.debug { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count == 0

      eligible_users = @scoring_rule.users_eligible_for_payouts

      users_with_holes_won = []

      eligible_users.each do |user|
      	match_play_scorecard = @scoring_rule.match_play_scorecard_for_user_in_team(user, nil)

      	users_with_holes_won << { user: user, holes_won: match_play_scorecard.holes_won }
      end

      # sort
      users_with_holes_won.sort! { |x,y| y[:holes_won] <=> x[:holes_won] }

      # assign payouts
      @scoring_rule.payouts.each_with_index do |payout, i|
      	if payout.payout_results.count.zero?
      		user = users_with_holes_won[i][:user]

      		if user.present?
      			Rails.logger.debug { "Assigning #{user.complete_name}. Payout [#{payout}] Scoring Rule [#{@scoring_rule.name} #{@scoring_rule.id}]" }

      			PayoutResult.create(payout: payout, user: user, scoring_rule: @scoring_rule, amount: payout.amount, points: payout.points)
      		end
      	else
      		Rails.logger.debug { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
      	end
      end
		end

	end
end