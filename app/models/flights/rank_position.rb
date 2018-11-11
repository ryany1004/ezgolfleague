module Flights
	class RankPosition
		attr_accessor :flight
    attr_accessor :sorted_results

    def self.compute_rank(flight)
    	rank_computer = self.new
    	rank_computer.flight = flight

      sort_param = "par_related_net_score"

    	if flight.tournament_day.game_type_id == 1
        rank_computer.sort_individual_stroke_play
    	elsif flight.tournament_day.game_type_id == 3
    		sort_param = "net_score"

    		rank_computer.sort_by_parameter(sort_param)
      elsif flight.tournament_day.game_type_id == 14
        rank_computer.combine_team_score_results
        rank_computer.sort_individual_stroke_play
    	else
    		rank_computer.sort_by_parameter(sort_param)
    	end

    	rank_computer.default_compute_rank(sort_param)
    end

    def tournament_day_results
      flight.tournament_day_results
    end

    def combine_team_score_results
      computed_teams = []
      team_results = []

      self.flight.users.each do |u|
        team = self.flight.tournament_day.golfer_team_for_player(u)
        unless team.blank? || computed_teams.include?(team)
          team.users.each do |team_user| #must re-score users first
            self.flight.tournament_day.score_user(team_user)
          end

          primary_user = team.users.first
          primary_scorecard = self.flight.tournament_day.primary_scorecard_for_user(primary_user)
          result_name = Users::ResultName.result_name_for_user(primary_user, self.flight.tournament_day)

          results = self.flight.tournament_day_results.where(user: team.users).where(aggregated_result: false)

          if results.sum(:net_score) > 0
            Rails.logger.info { "Summing results of #{results.count} results for team #{result_name}." }

            team_results << TournamentDayResult.new(aggregated_result: true, tournament_day: self.flight.tournament_day, user: primary_user, name: result_name, primary_scorecard: primary_scorecard, flight: self.flight, gross_score: results.sum(:gross_score), net_score: results.sum(:net_score), adjusted_score: results.sum(:adjusted_score), front_nine_gross_score: results.sum(:front_nine_gross_score), front_nine_net_score: results.sum(:front_nine_net_score), back_nine_net_score: results.sum(:back_nine_net_score), par_related_net_score: results.sum(:par_related_net_score), par_related_gross_score: results.sum(:par_related_gross_score))
          end

          computed_teams << team
        end
      end

      self.flight.tournament_day_results.destroy_all

      team_results.each do |r|
        r.save
      end

      self.tournament_day_results.reload
    end

    # Sort

    def sort_by_parameter(parameter)
    	self.sorted_results = tournament_day_results.reorder(parameter)
    end

     def sort_individual_stroke_play
      if game_type.use_back_9_to_break_ties?
        Rails.logger.info { "Tie-breaking is enabled" }

        if game_type.tournament_day.course_holes.count == 9 #if a 9-hole tournament, compare score by score
          Rails.logger.info { "9-Hole Tie-Breaking" }

          par_related_net_scores = tournament_day_results.map{ |x| x.par_related_net_score }

          if par_related_net_scores.uniq.length != par_related_net_scores.length
            Rails.logger.info { "We have tied players, using net_scores" }

            self.sorted_results = self.tournament_day_results.reorder("par_related_net_score, net_score")
          else
            Rails.logger.info { "No tied players..." }

            self.sorted_results = self.tournament_day_results.reorder("par_related_net_score, back_nine_net_score")
          end
        else
          Rails.logger.info { "18-Hole Tie-Breaking" }

          self.sorted_results = self.tournament_day_results.reorder("par_related_net_score, back_nine_net_score")
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

      Rails.logger.debug { "Ranking #{self.sorted_results.count} results" }

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

        Rails.logger.debug { "Rank of #{rank} for #{result.name}. Net score: #{result.net_score}. Back Nine Net Score (if applicable): #{result.back_nine_net_score}. Param: #{sort_parameter}: #{result.send(sort_parameter)}" }

        result.sort_rank = i
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