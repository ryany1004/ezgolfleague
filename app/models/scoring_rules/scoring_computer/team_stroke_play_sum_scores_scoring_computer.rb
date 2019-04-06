module ScoringComputer
	class TeamStrokePlaySumScoresScoringComputer < StrokePlayScoringComputer
		def generate_tournament_day_results
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

			user_scorecard = self.tournament_day.primary_scorecard_for_user(league_season_team.users.first) # TODO: this seems wrong

			TournamentDayResult.transaction do
				combined_team_result = @scoring_rule.tournament_day_results.find_or_create_by(aggregated_result: true, league_season_team: league_season_team)

				combined_team_result.name = league_season_team.name
				combined_team_result.primary_scorecard = user_scorecard
				combined_team_result.gross_score = team_member_results.sum(&:gross_score)
				combined_team_result.net_score = team_member_results.sum(&:net_score)
				combined_team_result.adjusted_score = team_member_results.sum(&:adjusted_score)
				combined_team_result.front_nine_gross_score = team_member_results.sum(&:front_nine_gross_score)
				combined_team_result.front_nine_net_score = team_member_results.sum(&:front_nine_net_score)
				combined_team_result.back_nine_net_score = team_member_results.sum(&:back_nine_net_score)
				combined_team_result.par_related_net_score = team_member_results.sum(&:par_related_net_score)
				combined_team_result.par_related_gross_score = team_member_results.sum(&:par_related_gross_score)

				combined_team_result.save
			end

  		combined_team_result
		end

		def assign_payouts
			Rails.logger.debug { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
			return if payout_count == 0

			primary_payout = @scoring_rule.payouts.first
			if primary_payout.apply_as_duplicates?
				self.tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
					PayoutResult.create(scoring_rule: @scoring_rule, league_season_team: matchup.winning_team, points: primary_payout.points)
				end
			else # walk down the list
				sorted_results = @scoring_rule.aggregate_tournament_day_results.reorder(:par_related_net_score)

				@scoring_rule.payouts.each_with_index do |p, i|
					PayoutResult.create(scoring_rule: @scoring_rule, league_season_team: sorted_results[i].league_season_team, points: p.points, amount: p.amount)
				end
			end
		end
	end
end