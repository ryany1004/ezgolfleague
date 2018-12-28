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
			
				score = 0

				@scoring_rule.course_holes.each do |hole|
					if use_gross_scores
						strokes = user_scorecard.scores.where(course_hole: hole).first.strokes
					else
						strokes = user_scorecard.scores.where(course_hole: hole).first.net_strokes
					end

					score += strokes
				end

				scores << { user: user, score: score }
			end

			scores
		end

		def sorted_results(scores: scores)
			scores.sort! { |x,y| x[:score] <=> y[:score] }
		end

		def total_value(scores: scores)
			(@scoring_rule.users_eligible_for_payouts.count * @scoring_rule.dues_amount).floor
		end

	end
end