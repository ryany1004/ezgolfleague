module ScoringComputer
	class StrokePlayScoringComputer < BaseScoringComputer
		def generate_tournament_day_result(user:)
			return nil if !@scoring_rule.users.include? user

			scorecard = self.tournament_day.primary_scorecard_for_user(user)
			return nil if scorecard.blank?

			handicap_computer = @scoring_rule.handicap_computer
			handicap_allowance = handicap_computer.handicap_allowance(user: user)
			Rails.logger.debug { "Handicap Allowance: #{handicap_allowance}" }

			flight = self.tournament_day.flight_for_player(user)
    	flight = self.tournament_day.assign_player_to_flight(user) if flight.blank?

			gross_score = 0
			net_score = 0
			front_nine_net_score = 0
			front_nine_gross_score = 0
			back_nine_net_score = 0

			adjusted_score = self.compute_adjusted_user_score(user: user)

			Rails.logger.debug { "Scoring #{scorecard.scores.count} scores for #{user.complete_name}." }

			scorecard.scores.includes(:course_hole).each do |score|
				gross_score += score.strokes
				front_nine_gross_score += score.strokes if self.front_nine_hole_numbers.include? score.course_hole.hole_number

				if handicap_allowance.present?
					handicap_allowance.each do |h|
						if h[:course_hole] == score.course_hole
							hole_net_score = score.strokes

							if h[:strokes] != 0
								hole_adjusted_score = score.strokes - h[:strokes]

	            	if hole_adjusted_score > 0
	            		hole_net_score = hole_adjusted_score
	            	end
							end

            	Rails.logger.debug { "Hole #{score.course_hole.hole_number} - Hole Net Score: #{hole_net_score}. Hole adjusted score: #{hole_adjusted_score}. Strokes: #{score.strokes}" }

            	net_score += hole_net_score
            	front_nine_net_score += hole_net_score if self.front_nine_hole_numbers.include? score.course_hole.hole_number
            	back_nine_net_score += hole_net_score if self.back_nine_hole_numbers.include? score.course_hole.hole_number
						end
					end
				else
					Rails.logger.debug { "No Handicap Allowance Present" }

					net_score = gross_score
				end
			end

	    user_par = self.user_par_for_played_holes(user)
	    par_related_net_score = net_score - user_par
	    par_related_gross_score = gross_score - user_par

	    result_name = Users::ResultName.result_name_for_user(user, self.tournament_day)

	    if gross_score > 0
	    	TournamentDayResult.transaction do
	    		@scoring_rule.tournament_day_results.where(user: user).destroy_all
	    		flight.tournament_day_results.where(user: user).destroy_all #TODO: Remove in future - needed for legacy tournaments

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

	    		Rails.logger.debug { "Writing tournament day result #{result}" }

	    		result
	    	end
	    else
	    	Rails.logger.debug { "Gross Score was #{gross_score}. Returning nil for tournament day result." }

	    	nil
	    end
		end

	  def user_par_for_played_holes(user)
	    par = 0

	    primary_scorecard = self.tournament_day.primary_scorecard_for_user(user)
	    return 0 if primary_scorecard.blank?

	    primary_scorecard.scores.each do |s|
	      if s.strokes > 0
	        par_adjustment = s.course_hole.par

	        par = par + par_adjustment
	      end
	    end

	    Rails.logger.debug { "User Par: #{par}" }

	    par
	  end

		def front_nine_hole_numbers
			[1, 2, 3, 4, 5, 6, 7, 8, 9]
		end

		def back_nine_hole_numbers
			[10, 11, 12, 13, 14, 15, 16, 17, 18]
		end

		def assign_payouts
			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count == 0

      eligible_users = @scoring_rule.users_eligible_for_payouts
      ranked_flights = self.ranked_flights

      ranked_flights.each do |flight|
        flight.payouts.each_with_index do |payout, i|

###
flight.tournament_day_results.each do |result|
	Rails.logger.debug { "#{result}" }
end
###


          if payout.payout_results.count == 0
            result = flight.tournament_day_results[i]

            if result.present? and eligible_users.include? result.user.id
              player = result.user

              Rails.logger.debug { "Assigning #{player.complete_name}. Result [#{result}] Payout [#{payout}]" }

              PayoutResult.create(payout: payout, user: player, scoring_rule: @scoring_rule, flight: flight, amount: payout.amount, points: payout.points)
            end
          else
            Rails.logger.debug { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
          end
        end
      end
		end

    def flights_with_rankings
    	self.tournament_day.flights.includes(:users, :tournament_day_results, :payout_results)
    end

    def ranked_flights
    	tournament = self.tournament_day.tournament
    	if tournament.tournament_days.count > 1
        rankings = []

        tournament.tournament_days.each do |day|
          rankings << day.flights_with_rankings
        end

        ranked_flights = tournament.combine_rankings(rankings)
    	else
    		flights_with_rankings
    	end
    end
	end
end