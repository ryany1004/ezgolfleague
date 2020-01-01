module ScoringComputer
	class LowScoringComputer < BaseScoringComputer
		def generate_tournament_day_result(user:)
			# low does not require TDR
		end

		def assign_payouts
			@scoring_rule.payout_results.destroy_all

			scores = self.user_scores(use_gross_scores: !@scoring_rule.use_net_score)
			sorted_scores = self.sorted_results(scores: scores)

			unless sorted_scores.count == 0
				win_value = self.total_value(scores: scores)

				winner = sorted_scores.first
				user = winner[:user]
				detail = winner[:score]

				PayoutResult.create(
					user: user,
					scoring_rule: @scoring_rule,
					amount: win_value,
					detail: detail,
					points: 0
				)
			end
		end
		
		def user_scores(use_gross_scores:)
			scores = []

			@scoring_rule.users_eligible_for_payouts.each do |user|
				user_scorecard = self.tournament_day.primary_scorecard_for_user(user)
				next if user_scorecard.blank?

				strokes = 0
				user_scorecard.scores.each do |score|
					if use_gross_scores
						strokes += score.strokes
					else
						strokes += score.net_strokes
					end
				end

				scores << { user: user, score: strokes } if strokes > 0
			end

			scores
		end

		def sorted_results(scores:)
			scores.sort! { |x,y| x[:score] <=> y[:score] }
		end

		def total_value(scores:)
			(@scoring_rule.users_eligible_for_payouts.count * @scoring_rule.dues_amount).floor
		end

	end
end