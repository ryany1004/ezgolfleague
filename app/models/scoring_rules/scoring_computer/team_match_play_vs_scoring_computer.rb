module ScoringComputer
	class TeamMatchPlayVsScoringComputer < MatchPlayScoringComputer
		def outcome_lists_include_user(outcome_lists, user)
			outcome_lists.each do |list|
				result = list.map(&:values).flatten.include? user

				return true if result
			end
			
			return false
		end

		def assign_payouts
			Rails.logger.debug { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count == 0

      eligible_users = @scoring_rule.users_eligible_for_payouts

      winners = []
      ties = []
      losers = []

      eligible_users.each do |user|
      	next if self.outcome_lists_include_user([winners, losers, ties], user) # this means we already handled this matchup

      	opponent = @scoring_rule.opponent_for_user(user)
      	next if opponent.blank?

      	if !eligible_users.include?(opponent) # opponent was disqualified, user wins
      		winners << user
      	else
      		user_match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(user)
      		if user_match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::WON #in this case, we are good
      			winners << { user: user, detail: user_match_play_scorecard.extra_scoring_column_data }
      		elsif user_match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::TIED
      			ties << { user: user, detail: user_match_play_scorecard.extra_scoring_column_data }

      			opponent_match_play_scorecard = @scoring_rule.match_play_scorecard_for_user(opponent)
      			ties << { user: opponent, detail: opponent_match_play_scorecard.extra_scoring_column_data }
      		elsif user_match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::LOST
      			losers << { user: user, detail: user_match_play_scorecard.extra_scoring_column_data }
      		end
      	end
      end

			primary_payout = @scoring_rule.payouts.first
			if primary_payout.apply_as_duplicates?
				winners.each do |u|
					PayoutResult.create(scoring_rule: @scoring_rule, user: u[:user], points: primary_payout.points, detail: u[:detail])
				end

				ties.each do |u|
					PayoutResult.create(scoring_rule: @scoring_rule, user: u[:user], points: primary_payout.points / 2, detail: u[:detail])
				end
			end
		end
	end
end