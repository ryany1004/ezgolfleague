module ScoringComputer
	class StrokePlayScoringComputer < BaseScoringComputer
		def rank_results_sort_reorder_param
      if @scoring_rule.use_back_9_to_break_ties?
        Rails.logger.info { "Tie-breaking is enabled" }

        if @scoring_rule.tournament_day.scorecard_base_scoring_rule.course_holes.count == 9 #if a 9-hole tournament, compare score by score
          Rails.logger.info { "9-Hole Tie-Breaking" }

          par_related_net_scores = scoring_rule.individual_tournament_day_results.map { |x| x.par_related_net_score }

          if par_related_net_scores.uniq.length != par_related_net_scores.length
            Rails.logger.info { "We have tied players, using net_scores" }

            reorder_param = "par_related_net_score, net_score"
          else
            Rails.logger.info { "No tied players..." }

            reorder_param = "par_related_net_score, back_nine_net_score"
          end
        else
          Rails.logger.info { "18-Hole Tie-Breaking" }

          reorder_param = "par_related_net_score, back_nine_net_score"
        end
      else
        Rails.logger.info { "Tie-breaking is disabled" }

        reorder_param = "par_related_net_score"
      end

      reorder_param
		end

		def generate_tournament_day_result(user:, scorecard: nil)
			return nil if !@scoring_rule.users.include? user

			user_scorecard = self.tournament_day.primary_scorecard_for_user(user)
			if scorecard.blank?
				scorecard = user_scorecard
				return nil if scorecard.blank?
			end

			handicap_computer = @scoring_rule.handicap_computer
			handicap_allowance = handicap_computer.handicap_allowance(user: user)
			Rails.logger.debug { "Handicap Allowance for User #{user.complete_name}: #{handicap_allowance}" }

			flight = self.tournament_day.flight_for_player(user)
    	flight = self.tournament_day.assign_user_to_flight(user: user) if flight.blank?

			gross_score = 0
			net_score = 0
			front_nine_net_score = 0
			front_nine_gross_score = 0
			back_nine_net_score = 0

			adjusted_score = self.compute_adjusted_user_score(user: user)

			Rails.logger.debug { "Scoring #{scorecard.scores.count} scores for #{user.complete_name}." }

			if scorecard.scores.respond_to?(:includes)
				scores = scorecard.scores.includes(:course_hole)
			else
				scores = scorecard.scores
			end

			scores.each do |score|
				score.net_strokes = score.strokes
				
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

            	# store net strokes
            	score.net_strokes = hole_net_score

            	# update stats
            	net_score += hole_net_score
            	front_nine_net_score += hole_net_score if self.front_nine_hole_numbers.include? score.course_hole.hole_number
            	back_nine_net_score += hole_net_score if self.back_nine_hole_numbers.include? score.course_hole.hole_number
						end
					end
				else
					Rails.logger.debug { "No Handicap Allowance Present" }

					net_score = gross_score
				end

				score.save
			end

	    user_par = self.user_par_for_played_holes(user)
	    par_related_net_score = net_score - user_par
	    par_related_gross_score = gross_score - user_par

	    result_name = Users::ResultName.result_name_for_user(user, self.tournament_day)
	    
	    if gross_score > 0
	    	result = @scoring_rule.tournament_day_results.find_or_create_by(user: user) #TODO: create_or_find_by
	    	
	    	result.name = result_name
	    	result.primary_scorecard = user_scorecard
	    	result.flight = flight
	    	result.gross_score = gross_score
	    	result.net_score = net_score
	    	result.adjusted_score = adjusted_score
	    	result.front_nine_gross_score = front_nine_gross_score
	    	result.front_nine_net_score = front_nine_net_score
	    	result.back_nine_net_score = back_nine_net_score
	    	result.par_related_net_score = par_related_net_score
	    	result.par_related_gross_score = par_related_gross_score

	    	result.save

    		Rails.logger.debug { "Writing tournament day result #{result}" }

    		result
	    else
	    	Rails.logger.debug { "Gross Score was #{gross_score}. Returning nil for tournament day result." }

	    	self.destroy_user_results(user)

	    	nil
	    end
		end

		def destroy_user_results(user)
			@scoring_rule.individual_tournament_day_results.where(user: user).destroy_all
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

		def assign_payouts
			Rails.logger.debug { "assign_payouts #{self.class}" }

			@scoring_rule.payout_results.destroy_all

			payout_count = @scoring_rule.payouts.count
			Rails.logger.debug { "Payouts: #{payout_count}" }
      return if payout_count == 0

      eligible_users = @scoring_rule.users_eligible_for_payouts
      ranked_flights = self.ranked_flights

      ranked_flights.each do |flight|
        flight.payouts.where(scoring_rule: @scoring_rule).each_with_index do |payout, i|
          if payout.payout_results.count == 0
            result = flight.tournament_day_results[i]

            if result.present? and eligible_users.include? result.user
              player = result.user

              Rails.logger.debug { "Assigning #{player.complete_name}. Result [#{result}] Payout [#{payout}] Scoring Rule [#{@scoring_rule.name} #{@scoring_rule.id}]" }

              PayoutResult.create(payout: payout, user: player, scoring_rule: @scoring_rule, flight: flight, amount: payout.amount, points: payout.points)
            end
          else
            Rails.logger.debug { "Payout Already Has Results: #{payout.payout_results.map(&:id)}" }
          end
        end
      end
		end
	end
end