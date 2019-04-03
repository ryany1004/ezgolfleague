module ScoringComputer
	class TeamStrokePlayVsScoringComputer < StrokePlayScoringComputer
		def assign_payouts
			Rails.logger.debug { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count == 0

      eligible_users = @scoring_rule.users_eligible_for_payouts

      winners = []
      losers = []

      eligible_users.each do |user|
      	next if winners.include?(user) || losers.include?(user) # this means we already handled this matchup

      	opponent = @scoring_rule.opponent_for_user(user)
      	next if opponent.blank?

      	if !eligible_users.include?(opponent) # opponent was disqualified, user wins
    			winners << user
    		else
	      	user_result = @scoring_rule.tournament_day_results.where(user: user).first
	      	opponent_result = @scoring_rule.tournament_day_results.where(user: opponent).first
	      	next if user_result.blank? && opponent_result.blank?

	      	if opponent_result.blank? || user_result.par_related_net_score < opponent_result.par_related_net_score
	      		winners << user
	      		losers << opponent
	      	else
	      		winners << opponent
	      		losers << user
	      	end
    		end
      end

			primary_payout = @scoring_rule.payouts.first
			if primary_payout.apply_as_duplicates?
				winners.each do |u|
					PayoutResult.create(scoring_rule: @scoring_rule, user: u, points: primary_payout.points)
				end
			end
		end
	end
end