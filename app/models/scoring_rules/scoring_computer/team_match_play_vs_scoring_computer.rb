module ScoringComputer
	class TeamMatchPlayVsScoringComputer < MatchPlayScoringComputer
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
	      	user_match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(user)
	      	if user_match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::WON #in this case, we are good
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