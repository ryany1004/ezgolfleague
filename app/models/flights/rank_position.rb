module Flights
	class RankPosition
		attr_accessor :flight
    attr_accessor :sorted_results

    def self.compute_rank(flight)
    	rank_computer = self.new
    	rank_computer.flight = flight

    	if flight.tournament_day.game_type == 1
    		sort_param = "par_related_net_score"

    		rank_computer.sort_individual_stroke_play
				rank_computer.individual_stroke_play_compute_rank
    	elsif flight.tournament_day.game_type == 3
    		sort_param = "net_score"

    		rank_computer.sort_by_parameter(sort_param)
    	else
     		sort_param = "par_related_net_score"

    		rank_computer.sort_by_parameter(sort_param)
    	end

    	rank_computer.default_compute_rank(sort_param)
    end

    def tournament_day_results
      flight.tournament_day_results
    end

    # Sort

    def sort_by_parameter(parameter)
    	self.sorted_results = tournament_day_results.sort { |x,y| x.send(parameter) <=> y.send(parameter) }
    end

     def sort_individual_stroke_play
      if game_type.use_back_9_to_break_ties?
        Rails.logger.info { "Tie-breaking is enabled" }

        if game_type.tournament_day.course_holes.count == 9 #if a 9-hole tournament, compare score by score
          Rails.logger.info { "9-Hole Tie-Breaking" }

          par_related_net_scores = tournament_day_results.map{ |x| x.par_related_net_score }

          if par_related_net_scores.uniq.length != par_related_net_scores.length
            Rails.logger.info { "We have tied players, using net_scores" }

            self.sorted_results.sort_by { |x| [x.par_related_net_score, x.net_scores] }
          else
            Rails.logger.info { "No tied players..." }

            self.sorted_results.sort_by { |x| [x.par_related_net_score, x.back_nine_net_score] }
          end
        else
          Rails.logger.info { "18-Hole Tie-Breaking" }

          self.sorted_results.sort_by { |x| [x.par_related_net_score, x.back_nine_net_score] }
        end
      else
        Rails.logger.info { "Tie-breaking is disabled" }

        self.sort_by_parameter("par_related_net_score")
      end
    end

    # Rank

    def default_compute_rank(sort_parameter)
      last_rank = 0
      last_score = 0
      quantity_at_rank = 0

      self.sorted_results.each_with_index do |result, i|
        #rank = last rank + 1
        #unless last_score are the same, then rank does not change
        #when last_score then does differ, need to move the rank up the number of slots

        if result.send(sort_parameter) != last_score
          rank = last_rank + 1

          if quantity_at_rank != 0
            quantity_at_rank = 0

            rank = i + 1
          end

          last_rank = rank
          last_score = result.send(sort_parameter)
        else
          if last_rank == 0
            rank = 1
          else
            rank = last_rank
          end

          quantity_at_rank = quantity_at_rank + 1
        end

        result.rank = rank
        result.save
      end
    end

    private

    def game_type
    	flight.tournament_day.game_type
    end

	end
end