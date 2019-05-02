module ScoringComputer
	class TeamMatchPlayBestBallScoringComputer < MatchPlayScoringComputer
		attr_accessor :winners
		attr_accessor :ties

		def initialize(scoring_rule)
			super(scoring_rule)

			self.winners = []
			self.ties = []
		end

		def generate_tournament_day_results
			individual_results = super

			self.tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
				team_a_best_ball_scorecard = self.best_ball_scorecard_for_team(matchup.team_a)
				team_b_best_ball_scorecard = self.best_ball_scorecard_for_team(matchup.team_b)

        Rails.logger.info { "TeamMatchPlayBestBallScoringComputer comparing #{matchup.team_a.name} and #{matchup.team_b.name}" }

				match_play_scorecard = ScoringRuleScorecards::TeamMatchPlayBestBallScorecard.new
		    match_play_scorecard.team_a_scorecard = team_a_best_ball_scorecard
		    match_play_scorecard.team_b_scorecard = team_b_best_ball_scorecard
		    match_play_scorecard.scoring_rule = @scoring_rule
		    match_play_scorecard.calculate_scores

				if match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::WON
					winners << { team: matchup.team_a, details: match_play_scorecard.extra_scoring_column_data }
					matchup.winning_team = matchup.team_a
					matchup.save
				elsif match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::LOST
          winners << { team: matchup.team_b, details: match_play_scorecard.extra_scoring_column_data }
          matchup.winning_team = matchup.team_b
          matchup.save
				elsif match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::TIED
					ties << { team: matchup.team_a, details: match_play_scorecard.extra_scoring_column_data }
					ties << { team: matchup.team_b, details: match_play_scorecard.extra_scoring_column_data }
        else
          Rails.logger.info { "TeamMatchPlayBestBallScoringComputer did not produce a final result for matchup #{matchup.id}. #{match_play_scorecard.extra_scoring_column_data}" }
				end
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
			Rails.logger.info { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.info { "Payouts: #{payout_count}" }
      return if payout_count.zero?

      # assign payouts
			primary_payout = @scoring_rule.payouts.first
			if primary_payout.apply_as_duplicates?
				# winners
				self.winners.each do |u|
					winning_team = u[:team]
					details = u[:details]

					PayoutResult.create(league_season_team: winning_team, scoring_rule: @scoring_rule, points: primary_payout.points, detail: details)
				end

				# ties
				self.ties.each do |u|
					winning_team = u[:team]
					details = u[:details]

					PayoutResult.create(league_season_team: winning_team, scoring_rule: @scoring_rule, points: primary_payout.points / 2, detail: details)
				end
			else
				raise "#{self.class} trying to be used with non splittable payouts."
			end
		end

	end
end
