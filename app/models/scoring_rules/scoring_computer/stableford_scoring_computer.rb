module ScoringComputer
	class StablefordScoringComputer < StrokePlayScoringComputer
		def rank_results_sort_descending
			true
		end

		def generate_tournament_day_result(user:, scorecard: nil, destroy_previous_results: true)
      scorecard = @scoring_rule.stableford_scorecard_for_user(user: user)
      return nil if scorecard.blank? || scorecard.scores.blank?

      if scorecard.gross_score > 0
      	result_name = Users::ResultName.result_name_for_user(user, self.tournament_day)

				flight = self.tournament_day.flight_for_player(user)
	    	flight = self.tournament_day.assign_user_to_flight(user: user) if flight.blank?

	    	TournamentDayResult.transaction do
	    		@scoring_rule.individual_tournament_day_results.where(user: user).destroy_all if destroy_previous_results

	    		gross_score = scorecard.gross_score
	    		net_score = scorecard.net_score

	    		result = @scoring_rule.tournament_day_results.create(
	    			user: user,
	    			name: result_name,
	    			primary_scorecard: self.tournament_day.primary_scorecard_for_user(user),
	    			flight: flight,
	    			gross_score: gross_score,
	    			net_score: net_score,
	    			adjusted_score: 0,
	    			front_nine_gross_score: 0,
	    			front_nine_net_score: 0,
	    			back_nine_net_score: 0,
	    			par_related_net_score: net_score,
	    			par_related_gross_score: gross_score)

	    		Rails.logger.debug { "Writing tournament day result #{result}" }

	    		result
	    	end
      else
	    	Rails.logger.debug { "Gross Score was #{gross_score}. Returning nil for tournament day result." }

	    	nil
      end
		end
	end
end