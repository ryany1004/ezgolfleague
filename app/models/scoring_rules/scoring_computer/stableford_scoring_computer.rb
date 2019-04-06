module ScoringComputer
	class StablefordScoringComputer < StrokePlayScoringComputer
		def rank_results_sort_descending
			true
		end

		def generate_tournament_day_result(user:, scorecard: nil)
      scorecard = @scoring_rule.stableford_scorecard_for_user(user: user)
      return nil if scorecard.blank? || scorecard.scores.blank?
      
      if scorecard.gross_score > 0
      	result_name = Users::ResultName.result_name_for_user(user, self.tournament_day)

				flight = self.tournament_day.flight_for_player(user)
	    	flight = self.tournament_day.assign_user_to_flight(user: user) if flight.blank?
	    	
    		gross_score = scorecard.gross_score
    		net_score = scorecard.net_score

    		TournamentDayResult.transaction do
		    	result = @scoring_rule.tournament_day_results.find_or_create_by(user: user)
		    	
		    	result.name = result_name
		    	result.primary_scorecard = self.tournament_day.primary_scorecard_for_user(user)
		    	result.flight = flight
		    	result.gross_score = gross_score
		    	result.net_score = net_score
		    	result.adjusted_score = 0
		    	result.front_nine_gross_score = 0
		    	result.front_nine_net_score = 0
		    	result.back_nine_net_score = 0
		    	result.par_related_net_score = net_score
		    	result.par_related_gross_score = gross_score

		    	result.save

	    		Rails.logger.debug { "Writing tournament day result #{result}" }

	    		result
		    end
      else
	    	Rails.logger.debug { "Gross Score was #{gross_score}. Returning nil for tournament day result." }

	    	self.destroy_user_results(user)

	    	nil
      end
		end
	end
end