module ScoringComputer
	class TeamMatchPlayBestBallScoringComputer < MatchPlayScoringComputer
		def generate_tournament_day_results
			individual_results = super

			self.tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
				team_a_best_ball_scorecard = self.best_ball_scorecard_for_team(matchup.team_a)
				team_b_best_ball_scorecard = self.best_ball_scorecard_for_team(matchup.team_b)

				match_play_scorecard = ScoringRuleScorecards::TeamMatchPlayBestBallScorecard.new
		    match_play_scorecard.team_a_scorecard = team_a_best_ball_scorecard
		    match_play_scorecard.team_b_scorecard = team_b_best_ball_scorecard
		    match_play_scorecard.scoring_rule = @scoring_rule
		    match_play_scorecard.calculate_scores

				# determine winner
				matchup.winning_team = match_play_scorecard.winning_team
				matchup.save
			end
		end

		def best_ball_scorecard_for_team(league_season_team)
	    scorecard = ScoringRuleScorecards::BestBallScorecard.new
	    scorecard.scoring_rule = @scoring_rule
	    scorecard.team = league_season_team
	    scorecard.users_to_compare = league_season_team.users 
	    scorecard.should_use_handicap = true
	    scorecard.calculate_scores

	    return scorecard
		end

		def assign_payouts
			Rails.logger.debug { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count == 0

      matchups = self.tournament_day.league_season_team_tournament_day_matchups

      # assign payouts
      @scoring_rule.payouts.each_with_index do |payout, i|
      	if payout.payout_results.count.zero? && matchups.count > i
      		winning_team = matchups[i].winning_team

      		if winning_team.present?
      			Rails.logger.debug { "Assigning #{winning_team.name}. Payout [#{payout}] Scoring Rule [#{@scoring_rule.name} #{@scoring_rule.id}]" }

      			PayoutResult.create(payout: payout, league_season_team: winning_team, scoring_rule: @scoring_rule, amount: payout.amount, points: payout.points)
      		end
      	else
      		Rails.logger.debug { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
      	end
      end
		end

	end
end