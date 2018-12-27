module ScoringComputer
	class SkinsScoringComputer < DailyTeamScoringComputer
		def generate_tournament_day_result(user:)
			# skins do not require TDR
		end

		def assign_payouts
			@scoring_rule.payout_results.destroy_all

			skins = self.users_with_skins(use_gross_scores: !@scoring_rule.use_net_score)
			per_skin = self.value_per_skin(skins: skins)

			skins.each do |s|
				scoring_rule_hole = @scoring_rule.scoring_rule_course_holes.where(course_hole: s[:hole].first)

				s[:winners].each do |winner|
					detail = "#{s[:hole].hole_number}"

					PayoutResult.create(
						user: winner,
						scoring_rule: @scoring_rule,
						amount: per_skin,
						scoring_rule_course_hole: scoring_rule_hole,
						detail: detail,
						points: 0)
				end
			end
		end

		def user_score_key(user:, hole:)
			"#{hole.id}-#{user.id}"
		end

		def value_per_skin(skins:)
			winners_sum = 0
			
			skins.each do |s|
				winners = s[:winners]

				winners_sum += winners.count
			end

			return if winners_sum.zero?

			total_pot = @scoring_rule.users_eligible_for_payouts.count * @scoring_rule.dues_amount

			if total_pot > 0
				(total_pot / winners_sum).floor
			else
				0
			end
		end

		def user_scores(use_gross_scores:)
			scores = {}

			self.users_eligible_for_payouts.each do |user|
				user_scorecard = self.tournament_day.primary_scorecard_for_user(user)
				next if user_scorecard.blank?
			
				@scoring_rule.course_holes.each do |hole|
					if use_gross_scores
						strokes = user_scorecard.scores.find_by_course_hole(hole).strokes
					else
						strokes = user_scorecard.scores.find_by_course_hole(hole).net_strokes
					end

					scores[self.user_score_key(user: user, hole: hole)] = strokes
				end
			end

			scores
		end

		def users_with_skins(use_gross_scores:)
			winners = []

			@scoring_rule.course_holes.each do |hole|
				users_with_skins = []
				user_scores = []

				self.users_eligible_for_payouts.each do |user|
					user_scorecard = self.tournament_day.primary_scorecard_for_user(user)
					next if user_scorecard.blank?

					strokes = hole_scores[self.user_score_key(user: user, hole: hole)]
					next if strokes.blank? || strokes.zero?

					user_scores << {user: user, score: strokes}
				end

				user_scores.sort! { |x,y| x[:score] <=> y[:score] }

				if !user_scores.empty?
					if user_scores.count == 1
						users_with_skins << user_scores[0][:user]

						Rails.logger.info { "Skins: User #{user_scores[0][:user].complete_name} got a regular skin for hole #{hole.hole_number}" }
					else
						if user_scores[0][:score] == user_scores[1][:score] #if there is a tie, they do not count
							Rails.logger.info { "Skins: There was a tie - no skin awarded. #{user_scores[0][:user].complete_name} and #{user_scores[1][:user].complete_name} for hole #{hole.hole_number}" }
						else
							users_with_skins << user_scores[0][:user]

							Rails.logger.info { "Skins: User #{user_scores[0][:user].complete_name} got a regular skin for hole #{hole.hole_number}" }
						end
					end
				end

				winners << { hole: hole, winners: users_with_skins }
			end

			winners
		end
		
	end
end