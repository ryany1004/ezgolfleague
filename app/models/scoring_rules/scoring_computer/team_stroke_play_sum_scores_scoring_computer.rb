module ScoringComputer
	class TeamStrokePlaySumScoresScoringComputer < StrokePlayScoringComputer
		def generate_tournament_day_results
			@scoring_rule.tournament_day_results.where(aggregated_result: true).destroy_all

			individual_results = super

			self.tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
				combined_results = []

				matchup.teams.each do |t|
					combined_results << self.combine_results_for_team(t, individual_results)
				end

				# determine winner
				matchup.winning_team = combined_results.sort { |x,y| x.par_related_net_score <=> y.par_related_net_score }.first.league_season_team
				matchup.save
			end
		end

		def combine_results_for_team(league_season_team, individual_results)
			team_member_results = []

			league_season_team.users.each do |u|
				team_member_results << individual_results.select { |r| r.user == u }.first
			end

			user_scorecard = self.tournament_day.primary_scorecard_for_user(league_season_team.users.first) #TODO: this seems wrong

  		combined_team_result = @scoring_rule.tournament_day_results.create(
  			aggregated_result: true,
  			league_season_team: league_season_team,
  			name: league_season_team.name,
  			primary_scorecard: user_scorecard,
  			gross_score: team_member_results.sum(&:gross_score),
  			net_score: team_member_results.sum(&:net_score),
  			adjusted_score: team_member_results.sum(&:adjusted_score),
  			front_nine_gross_score: team_member_results.sum(&:front_nine_gross_score),
  			front_nine_net_score: team_member_results.sum(&:front_nine_net_score),
  			back_nine_net_score: team_member_results.sum(&:back_nine_net_score),
  			par_related_net_score: team_member_results.sum(&:par_related_net_score),
  			par_related_gross_score: team_member_results.sum(&:par_related_gross_score))

  		team_member_results.map { |m| m.destroy }

  		combined_team_result
		end

		def assign_payouts
			Rails.logger.debug { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
			return if payout_count == 0

			if @scoring_rule.payouts.first.apply_as_duplicates?
				primary_payout = @scoring_rule.payouts.first

				self.tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
					PayoutResult.create(scoring_rule: @scoring_rule, points: primary_payout.points)
				end
			else
				#walk down the list
			end
		end

	end
end



		# def assign_payouts
		# 	Rails.logger.debug { "assign_payouts #{self.class}" }

		# 	@scoring_rule.payout_results.destroy_all

		# 	payout_count = @scoring_rule.payouts.count
		# 	Rails.logger.debug { "Payouts: #{payout_count}" }
  #     return if payout_count == 0

  #     eligible_users = @scoring_rule.users_eligible_for_payouts
  #     ranked_flights = self.ranked_flights

  #     ranked_flights.each do |flight|
  #       flight.payouts.where(scoring_rule: @scoring_rule).each_with_index do |payout, i|
  #         if payout.payout_results.count == 0
  #           result = flight.tournament_day_results[i]

  #           if result.present? and eligible_users.include? result.user
  #             player = result.user

  #             Rails.logger.debug { "Assigning #{player.complete_name}. Result [#{result}] Payout [#{payout}] Scoring Rule [#{@scoring_rule.name} #{@scoring_rule.id}]" }

  #             PayoutResult.create(payout: payout, user: player, scoring_rule: @scoring_rule, flight: flight, amount: payout.amount, points: payout.points)
  #           end
  #         else
  #           Rails.logger.debug { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
  #         end
  #       end
  #     end
		# end