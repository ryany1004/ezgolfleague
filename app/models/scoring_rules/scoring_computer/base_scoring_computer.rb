module ScoringComputer
	class BaseScoringComputer
		def initialize(scoring_rule)
			@scoring_rule = scoring_rule
		end

		def tournament_day
			@scoring_rule.tournament_day
		end

		def can_be_scored?
			true
		end

		def generate_tournament_day_result(user:, scorecard: nil)
			raise "Base class not implemented"
		end

		def generate_tournament_day_results
			results = []

			@scoring_rule.users.each do |u|
				results << self.generate_tournament_day_result(user: u)
			end

			results
		end

		def rank_results_sort_reorder_param
			"par_related_net_score"
		end

		def rank_results_sort_descending
			false
		end

		#some daily team types like two man stroke play return true to combine ranks
		def rank_should_combine_daily_team_results?
			false
		end

		def rank_results
			RankFlightsJob.perform_now(self.tournament_day)
		end

		def send_did_score_notification(scorecard:)
			SendComplicationNotificationJob.perform_later(scorecard)
		end

		def assign_payouts
			raise "Base class not implemented"
		end

		def after_updating_scores_for_scorecard(scorecard:)
			## Most scoring rules do not require after-action updating - commonly used to split scores, copy scores to teammates, etc...
		end

	  def compute_adjusted_user_score(user:)
	    return nil if !@scoring_rule.users.include? user

	    Rails.logger.info { "compute_adjusted_user_score: #{user.complete_name}" }

	    scorecard = @scoring_rule.tournament_day.primary_scorecard_for_user(user)
	    if scorecard.blank?
	      Rails.logger.info { "Returning 0 - No Scorecard" }

	      return 0
	    end

	    total_score = 0

	    scorecard_with_holes = Scorecard.where(id: scorecard.id).includes(scores: :course_hole).first
	    scorecard_with_holes.scores.each do |score|
	      adjusted_score = scorecard.score_or_maximum_for_hole(strokes: score.strokes, course_handicap: scorecard.golf_outing.course_handicap, hole: score.course_hole)

	      total_score = total_score + adjusted_score
	    end

	    Rails.logger.info { "User Adjusted Score: #{user.complete_name} - #{total_score}" }

	    total_score = 0 if total_score < 0

	    total_score
	  end

		def front_nine_hole_numbers
			[1, 2, 3, 4, 5, 6, 7, 8, 9]
		end

		def back_nine_hole_numbers
			[10, 11, 12, 13, 14, 15, 16, 17, 18]
		end

    def flights_with_rankings
    	self.tournament_day.flights_with_rankings
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