module ScoringComputer
	class StrokePlayScoringComputer < ScoringComputer
		def generate_tournament_day_result(user:)
			return nil if !@scoring_rule.users.include? user

			scorecard = self.tournament_day.primary_scorecard_for_user(user)
			return nil if scorecard.blank?

			handicap_allowance = self.tournament_day.handicap_allowance(user)
			Rails.logger.debug { "Handicap Allowance: #{handicap_allowance}" }

			flight = self.tournament_day.flight_for_player(user)
    	flight = self.tournament_day.assign_player_to_flight(user) if flight.blank?

			gross_score = 0
			net_score = 0
			front_nine_net_score = 0
			front_nine_gross_score = 0
			back_nine_net_score = 0

			adjusted_score = self.compute_adjusted_user_score(user: user)

			scorecard.scores.includes(:course_hole).each do |score|
				gross_score += score.strokes
				front_nine_gross_score += score.strokes if self.front_nine_hole_numbers.include? score.course_hole.hole_number

				if handicap_allowance.present?
					handicap_allowance.each do |h|
						if h[:course_hole] == score.course_hole && h[:strokes] != 0 #we have handicap for this hole
            	hole_adjusted_score = score.strokes - h[:strokes]
            	
            	if hole_adjusted_score > 0
            		hole_net_score = hole_adjusted_score
            	else
            		hole_net_score = score.strokes
            	end

            	net_score += hole_net_score
            	front_nine_net_score += net_score if self.front_nine_hole_numbers.include? score.course_hole.hole_number
            	back_nine_net_score += net_score if self.back_nine_hole_numbers.include? score.course_hole.hole_number
						end
					end
				end
			end

	    user_par = self.tournament_day.user_par_for_played_holes(user)
	    par_related_net_score = net_score - user_par
	    par_related_gross_score = gross_score - user_par

	    result_name = Users::ResultName.result_name_for_user(user, self)

	    if gross_score > 0
	    	TournamentDayResult.transaction do
	    		@scoring_rule.tournament_day_results.where(user: user).destroy_all
	    	
	    		result = @scoring_rule.tournament_day_results.create(
	    			user: user,
	    			name: result_name,
	    			primary_scorecard: scorecard,
	    			flight: flight,
	    			gross_score: gross_score,
	    			net_score: net_score,
	    			adjusted_score: adjusted_score,
	    			front_nine_gross_score: front_nine_gross_score,
	    			front_nine_net_score: front_nine_net_score,
	    			back_nine_net_score: back_nine_net_score,
	    			par_related_net_score: par_related_net_score,
	    			par_related_gross_score: par_related_gross_score)

	    		result
	    	end
	    else
	    	Rails.logger.debug { "Gross Score was #{gross_score}. Returning nil for tournament day result." }

	    	nil
	    end
		end

		def front_nine_hole_numbers
			[1, 2, 3, 4, 5, 6, 7, 8, 9]
		end

		def back_nine_hole_numbers
			[10, 11, 12, 13, 14, 15, 16, 17, 18]
		end

		def assign_payouts

		end
	end
end