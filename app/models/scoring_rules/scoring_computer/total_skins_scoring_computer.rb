module ScoringComputer
	class TotalSkinsScoringComputer < SkinsScoringComputer

		def assign_payouts
			@scoring_rule.payout_results.destroy_all
		
			gross_birdie_winners = users_with_gross_birdie_skins
			net_skins_winners = self.users_with_skins(use_gross_scores: false)
			merged_winners = self.merge_winners(gross_winners: gross_birdie_winners, net_winners: net_skins_winners)

			per_skin = self.value_per_skin(skins: merged_winners)

			Rails.logger.debug { "Rule #{@scoring_rule.id} value per skin: #{per_skin}" }

			merged_winners.each do |s|
				scoring_rule_hole = @scoring_rule.scoring_rule_course_holes.where(course_hole: s[:hole]).first

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

			self.combine_results(@scoring_rule.reload.payout_results, holes_are_unique: false)
		end

		def merge_winners(gross_winners:, net_winners:)
			all_winners = []

			gross_winners.each do |w|
				all_winners << w
			end

			net_winners.each do |w|
				all_winners.each do |all_winner|
					w[:winners].each do |w2|
						all_winner[:winners] << w2 if w[:hole] == all_winner[:hole]
					end
				end
			end

			all_winners
		end

		def users_with_gross_birdie_skins
			winners = []
			hole_scores = self.user_scores(use_gross_scores: true)

			@scoring_rule.course_holes.each do |hole|
				users_with_gross_birdie_skins = []

				gross_birdie_score = (hole.par - 1)

				@scoring_rule.users_eligible_for_payouts.each do |user|
					user_scorecard = self.tournament_day.primary_scorecard_for_user(user)
					next if user_scorecard.blank?

					strokes = hole_scores[self.user_score_key(user: user, hole: hole)]
					next if strokes.blank? || strokes.zero?

					if strokes <= gross_birdie_score # gross birdies or better count
						if @scoring_rule.team_type == ScoringRuleTeamType::DAILY # teams can only have ONE GROSS BIRDIE SKIN PER HOLE
							teammates_have_birdie_skin_for_hole = false

							daily_team = self.tournament_day.daily_team_for_player(user)
							if daily_team.present?
								daily_team.users.each do |teammate|
									teammates_have_birdie_skin_for_hole = true if gross_birdie_skins.include? teammate
								end
							end

							if !teammates_have_birdie_skin_for_hole
								Rails.logger.debug { "Skins: Team #{daily_team.id} for User #{user.id} DOES NOT Have Pre-Existing Birdies - Ok to Add" }
							
								users_with_gross_birdie_skins << user

								Rails.logger.info { "Skins: User #{user.complete_name} scored a gross birdie skin for hole #{hole.hole_number} w/ score #{strokes}. Required score: #{gross_birdie_score}" }
							end
						else # not a team contest
							users_with_gross_birdie_skins << user

							Rails.logger.info { "Skins: User #{user.complete_name} scored a gross birdie skin for hole #{hole.hole_number} w/ score #{strokes}. Required score: #{gross_birdie_score}" }
						end
					end
				end

				winners << { hole: hole, winners: users_with_gross_birdie_skins }
			end

			winners
		end

	end
end